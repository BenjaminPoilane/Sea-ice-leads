function [champ,masque,Xmin,Xmax,Ymin,Ymax]=projette(defo,res)
% 'defo' est un structure array qui doit avoir les donnees : 
%   - defo.data.dudx
%   - defo.data.dvdy
%   - defo.data.dudy
%   - defo.data.dvdx
%   - defo.data.xy_tricorner

% 'res' est la resolution (en mètres) désirée pour l'image matricielle à obtenir.
% Si on ne précise pas de valeur, 'res' est prise à 1 746 m, (résolution de
% la carte des cotes utilisée)

if exist('res')==0
    res= 1746;
end

% Liste des valeurs de cisaillement
    shear=sqrt((defo.data.dudx+defo.data.dvdy).*(defo.data.dudx+defo.data.dvdy)+(defo.data.dudy+defo.data.dvdx).*(defo.data.dudy+defo.data.dvdx)); 
% Liste des triangles, tableau de taille (nb de triangle x 3 x 2)
    triangle=defo.data.xy_tricorner;
% Nombre de triangles
    p=size(triangle,1);
% Abscisses et ordonnées min et max des champs de sortie
    Xmin=min(triangle(:,1,1))-10000;
    Xmax=max(triangle(:,1,1))+10000;
    Ymin=min(triangle(:,1,2))-10000;
    Ymax=max(triangle(:,1,2))+10000;
    Ymax=Ymin+res*floor((Ymax-Ymin)/res);
    Xmax=Xmin+res*floor((Xmax-Xmin)/res);

% Nombre de ligne, m, et de colonnes, n, des champs de sortie
    m=(Ymax-Ymin)/res;
    n=(Xmax-Xmin)/res;

% Initialisation
    champ = zeros(m,n);
    masque= zeros(m,n);
    
% Pour i parcourant tous les triangles
    for i=1:p
% Coordonnées extrêmes du triangle i        
        xmin=min(triangle(i,:,1));
        ymin=min(triangle(i,:,2));
        xmax=max(triangle(i,:,1));
        ymax=max(triangle(i,:,2));
% Matrice des coordonnées du triangle, et [1, 1, 1] en dernière ligne. 
% Un point (x,y) est dans le triangle si il existe [a;b;c] positifs tels que  A . [a;b;c] = [x;y;1]  
        A=[triangle(i,:,1);triangle(i,:,2);1,1,1];
% Inverse de A
        iA=A\eye(3,3);
% Pour (ii,jj) parcourant les pixels susceptibles d'etre dans le triangle i        
        for jj=max(1,floor((xmin-Xmin)/res)):min(n,floor((xmax-Xmin)/res)+1)
            for ii=max(1,floor((Ymax-ymax)/res)):min(m,floor((Ymax-ymin)/res)+1)
% (x,y), coordonnees du coin inférieur gauche du pixel               
               x=Xmin+jj*res;
               y=Ymax-ii*res;
% Si le centre du pixel est dans un triangle (i.e. les coeffs de a = iA . [x+res/2;y+res/2;1]  sont positifs), champ1(ii,jj)=shear1(i) et masque(ii,jj)=1               
               u=[x+res/2;y+res/2;1];
               a=iA*u;
               if a(1)>-10^-5 && a(2)>=-10^-5 && a(3)>=-10^-5 
                  champ(ii,jj) =shear(i);
                  masque(ii,jj)=1;
               end
            end
        end
    end
    
return
end