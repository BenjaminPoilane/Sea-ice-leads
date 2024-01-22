function [anis,pond]=analyseSimpleImage(champ,scalePix)
l= scalePix ;
masque=ones(size(champ));

[anis,pond,M0,angles]=anisotropie(champ,masque,l);

% anis est le champ d'anisotropie
% angles est le champ de direction d'anisotropie
% M0(i,j) est la somme des elements de 'champ' compris dans le disque
% centre en (i,j) et de diam�tre 'l'.


disp('')
disp('Preparation de l affichage des resultats (quelques minutes)...');

champAff=gray2colorbar(champ,masque,1,'gray2red');
%champAff=champ;
% PREPARATION DES ELLIPSES
e=max(1,min(11,round((l-20)*(10-1)/(700-20))+1));     % e : epaisseur du trace des ellipses
E=ellipsesOpt(anis,pond,angles,M0,l,e);      % E image en 0 et 1 des ellipses.
EAff=superpose1(champAff,E,[1,1,1]);               % On superpose les ellipses (en noir : [1,1,1] ) a champAff

%PREPARATION DU CHAMP D'ANISOTROPIE
anisMap=gray2colorbar(anis,masque,1,'blue2red');     %idem que pour l'affichage du champ, avec une colorbar 'blue2red'

% PREPARATION DE LA ROSE DES DIRECTIONS
[t,r]=roseDesDirections(32,angles,anis);

anisValues=anis(M0>=0.1);
disp('liste des valeurs d anisotropie stockee dans anisValues');
% Ne sont prises en compte que les valeurs de K du domaine d'analys(D==1) et calculees dans un disque d'analyse non vide (M0>0.1) 

anisMean=mean(anisValues);
disp(strcat('valeur moyenne de l anisotropie : ',num2str(anisMean)));
disp('cette valeur est stockee dans la variable anisMean');
bincount=histc(anisValues,[0:0.05:1]);
n=size(anisValues,1);
bin=bincount/n;

    % AFFICHAGE


figure('Name','Image de d�part','NumberTitle','off');imshow(champAff);
figure('Name','champ d anisotropie','NumberTitle','off');imshow(anisMap);
figure('Name',' Ellipses d anisotropie','NumberTitle','off');imshow(EAff);
figure('Name','Distribution des valeurs d anisotropie','NumberTitle','off');bar([0:0.05:1],bin);xlabel('anisotropy intensity');ylabel('frequency');
figure('Name','RoseDesDirections','NumberTitle','off');
h = rose(r,t);
x = get(h,'Xdata');
y = get(h,'Ydata');
g=patch(x,y,'y');
    % SAUVEGARDE DES IMAGES
    
imwrite(anisMap,strcat('ImagesDesChamps\AnisotropyMap_',num2str(l),'pix.tiff'));
imwrite(EAff,strcat('ImagesDesChamps\Ellipses_',num2str(l),'pix.tiff'));
imwrite(champAff,'ImagesDesChamps\Deformation_map.tiff');
end










