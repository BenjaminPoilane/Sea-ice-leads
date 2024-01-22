
    % PARAMETRES DE L'ANALYSE (a changer par l'utilisateur) : 

%structure array comprenant le champ de deformation     
defo=defo_mod;    
% Resolution (en m�tres) de l'image qui sera analysee:
res = 1000 ;  
%Seuil (en /jour) au-dessous duquel les valeurs sont considerees nulles. 
%0.1 est la transition ductile-fragile de la glace.
seuil  = 0.01;  
% Echelle (en kilom�tres) de l'analyse d'anisotropie:
scale  = 1;
% Proportion (entre 0 et 1) de l'aire d'un disque d'analyse non recouverte par des donn�es tolerable dans le cas d'un
% champ rgps : 
propMax=0; %Par defaut, 10% .
% 'proj', booleen decidant si la projection sur une grille de pixels doit
% etre faite ou si elle a deja ete faite
proj=0; % proj=1 : par defaut, on fait la projection



% POUR FAIRE L4ANALYSE D4UNE IMAGE DEJA SOUS FORME DE MATRICE : 
% prendre res= 1000;
% scale = <echelle desiree en pixels>
% proj = 0 ;



    %PARAMETRES DE L'AFFICHAGE:

% Bornes (en m�tres) pour l'affichage des champs, ces valeurs doivent �tre
% comprises entres les [XminCotes,...,YmaxCotes] (ecrites plus loin):
XminAff=-2400986;
XmaxAff=1824334;
YminAff=-1496854;
YmaxAff=2169746;
% valeur (en /jour) qui sera consideree comme maximum pour l'affichage du 
% champ de deformation (toutes les valeurs au-dessus seront affichees avec 
%la m�me intensite):
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


    % �PROJECTION SUR UNE GRILLE DE PIXELS 
%cette etape peut �tre passee si on a deja fait une analyse a une
%differente echelle avec : 
%  - le m�me champ 'defo'
%  - la m�me resolution 'res'
%  - le m�me seuil 'seuil'
% Dans ce cas, mettre le booleen 'proj' a 0. 
% Veillez a ce que tout soit bien stocke dans les variables : champ,
% masque, Xmin, Xmax, Ymin, Ymax

% Xmin, ... , Ymax sont des bornes (calculees par 'projette') encadrant
% tous les points de 'defo' ou il y a des donnees.

if  proj==1
    disp('Projection du champ sur une grille de pixels (quelques minutes)...');

    [champ,masque,Xmin,Xmax,Ymin,Ymax]=projette(defo,res);
    champ =(champ>=seuil).*champ;
end



disp('');
disp('Calcul de l anisotropie (peut prendre plusieurs dizaines de minutes)...');
l=round(1000*scale/res); % l est l'�chelle d'analyse en pixel

[anis,pond,M0,angles]=anisotropie(champ,masque,l);

% anis est le champ d'anisotropie
% angles est le champ de direction d'anisotropie
% M0(i,j) est la somme des elements de 'champ' compris dans le disque
% centre en (i,j) et de diam�tre 'l'.

if propMax==0
    se=strel('disk',floor(l/2)+1);
    D=1-imdilate(1-masque,se);
    % D est le domaine d'analyse. Seuls les valeurs K(i,j) tels que D(i,j)=1
    % seront prises en compte. D est l'ensembles des centres de disques de
    % diam�tre 'l' QUI N'INTERCEPTE AUCUNE ZONE SANS DONNEE.
elseif propMax<=1 && propMax>0
    D=domaine(masque,propMax,l);
    % le domaine d'analyse D est calcule en prenant les centres des disques
    % ayant au moins (1-propMax) pourcent de leur aire couverte par des 
    %donnees.
else
    error('propMax non compris entre 0 et 1');
end
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

% AFFICHAGE DU CHAMP DE DEFORMATION

% On met le champ suivant la colormap 'gray2red'
champAff=gray2colorbar(champ,masque,maxAff,'gray2red');
if (ismap ==1) 

champAff=uint8(passage(champAff,Xmin,Xmax,Ymin,Ymax,XminAff,XmaxAff,YminAff,YmaxAff,res)); %On redimensionne le champ pour qu'il soit entre les bornes
% d'affichage : [XminAff, ..., YmaxAff], grace a la fonction 'passage' .
masqueAff=passage(masque,Xmin,Xmax,Ymin,Ymax,XminAff,XmaxAff,YminAff,YmaxAff,res); % idem pour le masque
end
champAff=superpose1(champAff,1-masqueAff,[255,255,255]); % on superpose l'image en 'gray2red' redimensionnee aux zones sans donnees (en blanc) : ocean, 
%terre, et zones sans donnees grace a 'superpose1'
champAff=superpose1(champAff,cotesAff,[1,1,1]); % on superpose tout �a au cotes (en noir)

% PREPARATION DES ELLIPSES
e=max(1,min(11,round((l-20)*(10-1)/(700-20))+1));     % e : epaisseur du trace des ellipses
E=ellipsesOpt(anis.*D,pond.*D,angles,M0.*D,l,e);      % E image en 0 et 1 des ellipses.
EAff=passage(E,Xmin,Xmax,Ymin,Ymax,XminAff,XmaxAff,YminAff,YmaxAff,res); 
EAff=superpose1(champAff,EAff,[1,1,1]);               % On superpose les ellipses (en noir : [1,1,1] ) a champAff

%PREPARATION DU CHAMP D'ANISOTROPIE
anisMap=gray2colorbar(anis.*D,masque,1,'blue2red');     %idem que pour l'affichage du champ, avec une colorbar 'blue2red'
anisMap=uint8(passage(anisMap,Xmin,Xmax,Ymin,Ymax,XminAff,XmaxAff,YminAff,YmaxAff,res));
anisMap=superpose1(anisMap,1-masqueAff,[255,255,255]);
anisMap=superpose1(anisMap,cotesAff,[1,1,1]);

% PREPARATION DE LA ROSE DES DIRECTIONS
[t,r]=roseDesDirections(32,angles,anis.*D);

anisValues=anis(find((D>=1).*(M0>=0.1)));
disp('liste des valeurs d anisotropie stockee dans anisValues');
% Ne sont prises en compte que les valeurs de K du domaine d'analys(D==1) et calculees dans un disque d'analyse non vide (M0>0.1) 

anisMean=mean(anisValues);
disp(strcat('valeur moyenne de l anisotropie : ','num2str(anisMean)'));
disp('cette valeur est stockee dans la variable anisMean');
bincount=histc(anisValues,[0:0.05:1]);
n=size(anisValues,1);
bin=bincount/n;

    % AFFICHAGE

figure('Name','RoseDesDirections','NumberTitle','off');rose(r,t);
figure('Name','Champ de deformation','NumberTitle','off');imshow(champAff);
figure('Name','champ d anisotropie','NumberTitle','off');imshow(anisMap);
figure('Name',' Ellipses d anisotropie','NumberTitle','off');imshow(EAff);
figure('Name','Distribution des valeurs d anisotropie','NumberTitle','off');bar([0:0.05:1],bin);

    % SAUVEGARDE DES IMAGES
    
imwrite(anisMap,strcat('ImagesDesChamps\AnisotropyMap_',num2str(scale),'km.tiff'));
imwrite(EAff,strcat('ImagesDesChamps\Ellipses_',num2str(scale),'km.tiff'));
imwrite(champAff,'ImagesDesChamps\Deformation_map.tiff');










