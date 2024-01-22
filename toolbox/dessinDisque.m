function B=dessinDisque(h) %// créé une matrice nulle avec des 1 dans un disque inclus dans la matrice centré en son milieu et de rayon maximal (n/2)
    B=zeros(h,h);
    ii0=(h+1)/2;
    jj0=(h+1)/2;
    for ii=1:h
        for jj=1:h
            if (ii-ii0)^2+(jj-jj0)^2<=(h/2)^2 
                B(ii,jj)=1;
            end
        end
    end
    return
end