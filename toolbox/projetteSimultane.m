function [champ1,champ2,masque1,masque2,Xmin,Xmax,Ymin,Ymax]=projetteSimultane(defo1,defo2,res)
% Cette fonction est analogue à la fonction 'projette' sauf qu'elle prend
% soin de projetté les champs contenus dans defo1 et defo2 exactement de la
% meme maniere: la resolution est la même et le domaine (défini par xmin,
% xmax, ymin et ymax) est le meme pour les deux champs. Il est pris les
% plus réduit possible pour contenir au moins un champ entierement.

% Si 'res' n'est pas définie, on prend la valeur 1 746 m. 
if exist('res')==0
    res=1746;
end


% Listes des valeurs de cisaillement
    shear1=sqrt((defo1.data.dudx+defo1.data.dvdy).*(defo1.data.dudx+defo1.data.dvdy)+(defo1.data.dudy+defo1.data.dvdx).*(defo1.data.dudy+defo1.data.dvdx)); 
    shear2=sqrt((defo2.data.dudx+defo2.data.dvdy).*(defo2.data.dudx+defo2.data.dvdy)+(defo2.data.dudy+defo2.data.dvdx).*(defo2.data.dudy+defo2.data.dvdx));
% Listes des triangles, tableaux de taille (nb de triangle x 3 x 2)
    triangle1=defo1.data.xy_tricorner;
    triangle2=defo2.data.xy_tricorner;
% Nombre de triangles
    p1=size(triangle1,1);
    p2=size(triangle2,1);
% Abscisses et ordonnées min et max de chaque champ (avec une marge de 10km au dessus et en dessous)
    Xmin1=min(triangle1(:,1,1))-10000;
    Xmax1=max(triangle1(:,1,1))+10000;
    Ymin1=min(triangle1(:,1,2))-10000;
    Ymax1=max(triangle1(:,1,2))+10000;
    Xmin2=min(triangle2(:,1,1))-10000;
    Xmax2=max(triangle2(:,1,1))+10000;
    Ymin2=min(triangle2(:,1,2))-10000;
    Ymax2=max(triangle2(:,1,2))+10000;
% Abscisses et ordonnées min et max des champs de sortie
    Xmin=max(Xmin1,Xmin2);
    Xmax=min(Xmax1,Xmax2);
    Ymin=min(Ymin1,Ymin2);
    Ymax=min(Ymax1,Ymax2);
    Ymax=Ymin+res*floor((Ymax-Ymin)/res);
    Xmax=Xmin+res*floor((Xmax-Xmin)/res);

% Nombre de ligne, m, et de colonnes, n, des champs de sortie
    m=(Ymax-Ymin)/res;
    n=(Xmax-Xmin)/res;
% Initialisation
    champ1 = zeros(m,n);
    champ2 = zeros(m,n);
    masque1= zeros(m,n); 
    masque2= zeros(m,n);
    
% Pour i parcourant tous les triangles de defo1
    for i=1:p1
% Coordonnées extrêmes du triangle i        
        xmin=min(triangle1(i,:,1));
        ymin=min(triangle1(i,:,2));
        xmax=max(triangle1(i,:,1));
        ymax=max(triangle1(i,:,2));
% Matrice des coordonnées du triangle, et [1, 1, 1] en dernière ligne. 
% Un point (x,y) est dans le triangle si il existe [a;b;c] positifs tels que  A . [a;b;c] = [x;y;1]  
        A=[triangle1(i,:,1);triangle1(i,:,2);1,1,1];
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
                  champ1(ii,jj) =shear1(i);
                  masque1(ii,jj)=1;
               end
            end
        end
    end
    
% Idem pour les triangles de defo2
    
    for i=1:p2
            xmin=min(triangle2(i,:,1));
            ymin=min(triangle2(i,:,2));
            xmax=max(triangle2(i,:,1));
            ymax=max(triangle2(i,:,2));
            A=[triangle2(i,:,1);triangle2(i,:,2);1,1,1];
            iA=A\eye(3,3);
            for jj=max(1,floor((xmin-Xmin)/res)):min(n,floor((xmax-Xmin)/res)+1)
                for ii=max(1,floor((Ymax-ymax)/res)):min(m,floor((Ymax-ymin)/res)+1)
                   x=Xmin+jj*res;
                   y=Ymax-ii*res;
                   u=[x+res/2;y+res/2;1];
                   a=iA*u;
                   if a(1)>-10^-5 && a(2)>=-10^-5 && a(3)>=-10^-5 
                      champ2(ii,jj)=shear2(i);
                      masque2(ii,jj)=1;
                   end
                end
            end
        end


return


end