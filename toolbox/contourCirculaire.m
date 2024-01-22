function [cont]=contourCirculaire(rayon,cote)    % calcul le contour d'un disque, matrice nulle de taille rayon x rayon avec un disque de rayon rayon/2 rempli de 1
%attention, la notation rayon est nulle, il s'agit en fait du diametre de
%la boite!

cont0=zeros(rayon,rayon);
cont=[];
i0=(rayon+1)/2;
j0=(rayon+1)/2;
for i=1:rayon
    for j=1:rayon
        if ((i-i0)^2+(j-j0)^2)<=(rayon/2)^2 
            
                
                
                if strcmp(cote,'droite')&& ((i-i0)^2+(j-j0+1)^2)>(rayon/2)^2
                    cont=[cont;i,j];
                    cont0(i,j)=1;
                end
                if strcmp(cote,'gauche')&&((i-i0)^2+(j-j0-1)^2)>(rayon/2)^2
                    cont=[cont;i,j];
                    cont0(i,j)=1;
                 end
                 if  strcmp(cote,'haut')&&((i-i0-1)^2+(j-j0)^2)>(rayon/2)^2
                    cont=[cont;i,j];
                    cont0(i,j)=1;
                 end
                 if  strcmp(cote,'bas')&& ((i-i0+1)^2+(j-j0)^2)>(rayon/2)^2
                    cont=[cont;i,j];
                    cont0(i,j)=1;
                 end     
                
        end
    end
end





return
end