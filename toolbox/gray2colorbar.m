function M2=gray2colorbar(M,masque,max,colorbar)
% Fonction qui transforme une image en nuance de gris en suivant une
% colorbar. 
% M : image en niveau de gris
% masque : masque auquel sera restreinte la transformation (là où masque=0, on laisse en
% niveau de gris)
% max : valeur correspondant au maximum de la colorbar.
% colorbar : string correspondant à la colorbar choisie : choix entre
% 'gray2red', 'blue2red', 'jet', 'gray'


if strcmp(colorbar,'gray2red')
    h=gray2red(256);
elseif strcmp(colorbar,'blue2red')
    h=blue2red(256);
elseif strcmp(colorbar,'jet')
    h=jet(256);
elseif strcmp(colorbar,'gray')
    h=gray(256);
else
    error('colorbar inconnue');
end
M2=zeros(size(M,1),size(M,2),3);
M1=1+floor(256*M/max);

for i=1:size(h)
    
    A=(M1==i);
    M2(:,:,1)=M2(:,:,1)+(floor(255*h(i,1))*A).*masque;
    M2(:,:,2)=M2(:,:,2)+(floor(255*h(i,2))*A).*masque;
    M2(:,:,3)=M2(:,:,3)+(floor(255*h(i,3))*A).*masque;
end
    A=(M1>=i);
    M2(:,:,1)=M2(:,:,1)+(floor(255*h(i,1))*A).*masque;
    M2(:,:,2)=M2(:,:,2)+(floor(255*h(i,2))*A).*masque;
    M2(:,:,3)=M2(:,:,3)+(floor(255*h(i,3))*A).*masque;
M2=uint8(M2);
return;
end
