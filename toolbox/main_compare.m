
    % PARAMETRES DE L'ANALYSE : 

%structure array comprenant le champ de deformation     
defo1=defo_mod;    
defo2=defo_rgps;
% Resolution (en mètres) de l'image qui sera analysee:
res = 1746 ;  
%Seuil1 et seuil2 sont les seuils (en /jour) au-dessous desquel les valeurs des champ 1 et 2 sont considerees nulles. 
%0.1 est la transition ductile-fragile de la glace.
seuil1  = 0.01;  
seuil2  = 0.01;
% Echelle (en kilomètres) de l'analyse d'anisotropie:
scale  = 50;
% Proportion (entre 0 et 1) de l'aire d'un disque d'analyse tolerable dans le cas d'un
% champ rgps : 
propMax=0.9; %Par defaut, 10% .
% 'proj', booleen decidant si la projection sur une grille de pixels doit
% etre faite ou si elle a deja ete faite
proj=1; % par defaut, on fait la projection


    %PARAMETRES DE L'AFFICHAGE:

% Bornes (en mètres) pour l'affichage des champs, ces valeurs doivent être
% comprises entres les [XminCotes,...,YmaxCotes] (ecrites plus loin):
XminAff=-2400986;
XmaxAff=1824334;
YminAff=-1496854;
YmaxAff=2169746;
% valeur (en /jour) qui sera consideree comme maximum pour l'affichage du 
% champ de deformation (toutes les valeurs au-dessus seront affichees avec 
%la même intensite):
maxAff=0.1;


% LA DUREE D'EXECUTION DU PROGRAMME AUGMENTE FORTEMENT AVEC LE RAPPORT
% scale/'res. 
%PRENDRE propMax=0 RACCOURCIT L'EXECUTION (A PRENDRE SEULEMENT POUR DES
%SORTIES DE MODELES).

if 1000*scale< 8*res
    error('l echelle d analyse trop faible pour la resolution choisie');
end

disp(strcat('resolution : ',num2str(res),' m'));
disp(strcat('echelle d analyse : ',num2str(scale),' km'));
disp(strcat('seuil de prise en compte des valeurs : ',num2str(seuil),' /jour'));
disp(' ');


    % ¨PROJECTION SUR UNE GRILLE DE PIXELS 
%cette etape peut être passee si on a deja fait une analyse a une
%differente echelle avec : 
%  - le même champ 'defo'
%  - la même resolution 'res'
%  - le même seuil 'seuil'
% Dans ce cas, mettre le booleen 'proj' a 0. 
% Veillez a ce que tout soit bien stocke dans les variables : champ,
% masque, Xmin, Xmax, Ymin, Ymax

% Xmin, ... , Ymax sont des bornes (calculees par 'projette') encadrant
% tous les points de 'defo' ou il y a des donnees.

if  proj==1
    disp('Projection du champ sur une grille de pixels (quelques minutes)...');

    [champ1,champ2,masque1,masque2,Xmin,Xmax,Ymin,Ymax]=projetteSimultane(defo1,defo2,res);
    champ1 =(champ1>=seuil1).*champ1;
    champ2 =(champ2>=seuil2).*champ2;
end



disp('');
disp('Calcul de l anisotropie (peut prendre plusieurs dizaines de minutes)...');
l=round(1000*scale/res);

[anis1,pond1,M01,angles1]=anisotropie(champ1,masque1,l);
[anis2,pond2,M02,angles2]=anisotropie(champ2,masque2,l);

% anis est le champ d'anisotropie
% angles est le champ de direction d'anisotropie
% M0(i,j) est la somme des elements de 'champ' compris dans le disque
% centre en (i,j) et de diamètre 'l'.

if propMax==0
    se=strel('disk',floor(l/2)+1);
    D1=1-imdilate(1-masque1,se);
    D2=1-imdilate(1-masque2,se);
    % D est le domaine d'analyse. Seuls les valeurs K(i,j) tels que D(i,j)=1
    % seront prises en compte. D est l'ensembles des centres de disques de
    % diamètre 'l' QUI N'INTERCEPTE AUCUNE ZONE SANS DONNEE.
elseif propMax<=1 && propMax>0
    D1=domaine(masque1,propMax,l);
    D2=domaine(masque2,propMax,l);
    
    % le domaine d'analyse D est calcule en prenant les centres des disques
    % ayant au moins (1-propMax) pourcent de leur aire couverte par des 
    %donnees.
else
    error('propMax non compris entre 0 et 1');
end
D=D1.*D2;
disp('')
disp('Preparation de l affichage des resultats (quelques minutes)...');

load('cotes.mat');
XminCotes=-4.5992*10^6;
XmaxCotes= 3.7127*10^6;
YminCotes=-4.5424*10^6;
YmaxCotes= 4.6124*10^6;


if res~=1746
% la resolution de la carte des cotes inclue dans la tool box est de 1746,
% si res est different, il faut convertir cette carte avec la nouvelle
% resolution et la redimensionner pour qu'on affiche que entre
% XminAff,...YmaxAff, ce que fait la fonction 'convertion'
    cotesAff=convertion(cotes,XminCotes,XmaxCotes,YminCotes,YmaxCotes,XminAff,XmaxAff,YminAff,YmaxAff,1746,res);
else
% si 'res' vaut 1746, il suffit de redimensionner, avec la fonction
% 'passage'
    cotesAff=passage(cotes,XminCotes,XmaxCotes,YminCotes,YmaxCotes,XminAff,XmaxAff,YminAff,YmaxAff,res);
end

% AFFICHAGE DES CHAMPS DE DEFORMATION
champAff1=gray2colorbar(champ1,masque1,maxAff,'gray2red'); % On met le champ suivant la colormap 'gray2red'
champAff1=uint8(passage(champAff1,Xmin,Xmax,Ymin,Ymax,XminAff,XmaxAff,YminAff,YmaxAff,res)); %On redimensionne le champ pour qu'il soit entre les bornes
% d'affichage : [XminAff, ..., YmaxAff], grace a la fonction 'passage' .
masqueAff1=passage(masque1,Xmin,Xmax,Ymin,Ymax,XminAff,XmaxAff,YminAff,YmaxAff,res); % idem pour le masque
champAff1=superpose1(champAff1,1-masqueAff1,[255,255,255]); % on superpose l'image en 'gray2red' redimensionnee aux zones sans donnees (en blanc) : ocean, 
%terre, et zones sans donnees grace a 'superpose1'
champAff1=superpose1(champAff1,cotesAff,[1,1,1]); % on superpose tout ça au cotes (en noir)

champAff2=gray2colorbar(champ2,masque2,maxAff,'gray2red'); % On met le champ suivant la colormap 'gray2red'
champAff2=uint8(passage(champAff2,Xmin,Xmax,Ymin,Ymax,XminAff,XmaxAff,YminAff,YmaxAff,res)); %On redimensionne le champ pour qu'il soit entre les bornes
% d'affichage : [XminAff, ..., YmaxAff], grace a la fonction 'passage' .
masqueAff2=passage(masque2,Xmin,Xmax,Ymin,Ymax,XminAff,XmaxAff,YminAff,YmaxAff,res); % idem pour le masque
champAff2=superpose1(champAff2,1-masqueAff2,[255,255,255]); % on superpose l'image en 'gray2red' redimensionnee aux zones sans donnees (en blanc) : ocean, 
%terre, et zones sans donnees grace a 'superpose1'
champAff2=superpose1(champAff2,cotesAff,[1,1,1]);

% PREPARATION DES ELLIPSES
e=max(1,min(11,round((l-20)*(10-1)/(700-20))+1));        % e : epaisseur du trace des ellipses
E1=ellipsesOpt(anis1.*D1,pond1.*D1,angles1,M01.*D1,l,e); % E image en 0 et 1 des ellipses.
EAff1=passage(E1,Xmin,Xmax,Ymin,Ymax,XminAff,XmaxAff,YminAff,YmaxAff,res);  % On superpose les ellipses (en noir) a champAff
EAff1=superpose1(champAff1,EAff1,[1,1,1]);

E2=ellipsesOpt(anis2.*D2,pond2.*D2,angles2,M02.*D2,l,e); % E image en 0 et 1 des ellipses.
EAff2=passage(E2,Xmin,Xmax,Ymin,Ymax,XminAff,XmaxAff,YminAff,YmaxAff,res);  % On superpose les ellipses (en noir) a champAff
EAff2=superpose1(champAff2,EAff2,[1,1,1]);

%PREPARATION DU CHAMP D'ANISOTROPIE
anisMap1=gray2colorbar(anis1.*D1,masque1,1,'blue2red');     %idem que pour l'affichage du champ, avec une colorbar 'blue2red'
anisMap1=uint8(passage(anisMap1,Xmin,Xmax,Ymin,Ymax,XminAff,XmaxAff,YminAff,YmaxAff,res));
anisMap1=superpose1(anisMap1,1-masqueAff1,[255,255,255]);
anisMap1=superpose1(anisMap1,cotesAff,[1,1,1]);

anisMap2=gray2colorbar(anis2.*D2,masque2,1,'blue2red');     %idem que pour l'affichage du champ, avec une colorbar 'blue2red'
anisMap2=uint8(passage(anisMap2,Xmin,Xmax,Ymin,Ymax,XminAff,XmaxAff,YminAff,YmaxAff,res));
anisMap2=superpose1(anisMap2,1-masqueAff2,[255,255,255]);
anisMap2=superpose1(anisMap2,cotesAff,[1,1,1]);

% PREPARATION DE LA ROSE DES DIRECTIONS
% Pour les roses des directions et les distributions des valeurs d'anisotropie, le domaine d'analyse utilisé est
% l'intersection des deux domaines afin que l'on compare bien les
% directions sur les mêmes domaines.
% (généralement, l'intersection des deux domaines se ramène au domaine des
% données RGPS)

[t1,r1]=roseDesDirections(32,angles1,anis1.*D);
[t2,r2]=roseDesDirections(32,angles2,anis2.*D);

anisValues1=anis1(find((D>=1).*(M01>=0.1)));
anisValues2=anis2(find((D>=1).*(M02>=0.1)));
disp('liste des valeurs d anisotropie stockee dans anisValues');
% Ne sont prises en compte que les valeurs de K du domaine d'analys(D==1) et calculees dans un disque d'analyse non vide (M0>0.1) 

anisMean1=mean(anisValues1);
anisMean2=mean(anisValues2);
disp(strcat('valeur moyenne de l anisotropie du champ 1: ',num2str(anisMean1)));
disp(strcat('valeur moyenne de l anisotropie du champ 2: ',num2str(anisMean2)));
disp('ces valeurs sont stockees dans les variables anisMean1 et anisMean2');
bincount1=histc(anisValues1,[0:0.05:1]);
n1=size(anisValues1,1);
bin1=bincount1/n1;

bincount2=histc(anisValues2,[0:0.05:1]);
n2=size(anisValues2,1);
bin2=bincount2/n2;

    % AFFICHAGE

figure('Name','RoseDesDirections du champ 1','NumberTitle','off');rose(r1,t1);
figure('Name','RoseDesDirections du champ 2','NumberTitle','off');rose(r2,t2);

figure('Name','Champ de deformation du champ 1','NumberTitle','off');imshow(champAff1);
figure('Name','Champ de deformation du champ 2','NumberTitle','off');imshow(champAff2);

figure('Name','champ d anisotropie du champ 1','NumberTitle','off');imshow(anisMap1);
figure('Name','champ d anisotropie du champ 2','NumberTitle','off');imshow(anisMap2);

figure('Name',' Ellipses d anisotropie du champ 1','NumberTitle','off');imshow(EAff1);
figure('Name',' Ellipses d anisotropie du champ 2','NumberTitle','off');imshow(EAff2);

figure('Name','Distribution des valeurs d anisotropie du champ 1','NumberTitle','off');bar([0:0.05:1],bin1);
figure('Name','Distribution des valeurs d anisotropie du champ 2','NumberTitle','off');bar([0:0.05:1],bin2);
    % SAUVEGARDE DES IMAGES
    
imwrite(anisMap1,strcat('ImagesDesChamps\AnisotropyMap1_',num2str(scale),'km.tiff'));
imwrite(anisMap1,strcat('ImagesDesChamps\Ellipses1_',num2str(scale),'km.tiff'));
imwrite(anisMap1,'ImagesDesChamps\Deformation_map1.tiff');

imwrite(anisMap2,strcat('ImagesDesChamps\AnisotropyMap2_',num2str(scale),'km.tiff'));
imwrite(anisMap2,strcat('ImagesDesChamps\Ellipses2_',num2str(scale),'km.tiff'));
imwrite(anisMap2,'ImagesDesChamps\Deformation_map2.tiff');



 





