function A=superpose1(B0,C0,couleur0)
% Cette fonction renvoie une image A qui est l'image C0 en couleur couleur0
% (couleur0 doit etre un triplet de uint8 [r,g,b] pour le codage RGB)
% superposee à l'image B0 en noir et blanc si B0 n'était pas en couleur, ou
% sur B0 si B0 était déjà en couleur. 

% La matrice A vaudra donc les valeurs de B0 lorsque C0 est nul, et C0
% converti en couleur ailleurs?

B=double(B0);
C=double(C0);
couleur=double(couleur0);
s=size(B);
    t=size(s);
    if t(2)==3 
        A=B;
    end
    if t(2)==2 
        A=zeros(s(1),s(2),3);
        A(:,:,1)=255*B;
        A(:,:,2)=255*B;
        A(:,:,3)=255*B;
    end
    A(:,:,1)=A(:,:,1)-A(:,:,1).*C;
    A(:,:,2)=A(:,:,2)-A(:,:,2).*C;
    A(:,:,3)=A(:,:,3)-A(:,:,3).*C;
    rouge=floor(couleur(1));
    vert =floor(couleur(2));
    bleu =floor(couleur(3));
    A(:,:,3)=A(:,:,3)+bleu*C;
    A(:,:,1)=A(:,:,1)+rouge*C;
    A(:,:,2)=A(:,:,2)+vert*C;
    A=uint8(A);
    
    return
end