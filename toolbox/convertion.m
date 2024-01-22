% Converti le champ de mat0 entre Xmin0,Xmax0 et Ymin0, Ymax0 à la
% resolution res0 en un champ dans mat1 entre Xmin1,Xmax1,Ymin1 et Ymax1 à
% la résolution res1, en completant par des 0 si besoin est. 
function [mat1]=convertion(mat0,Xmin0,Xmax0,Ymin0,Ymax0,Xmin1,Xmax1,Ymin1,Ymax1,res0,res1)
[m0,n0]=size(mat0);
    m=floor((Ymax1-Ymin1)/res1)+1;
    n=floor((Xmax1-Xmin1)/res1)+1;
    
    mat1=zeros(m,n);
    
    for i=1:m
        for j=1:n
            x=Xmin1+ j*res1;
            y=Ymax1 - i*res1;
            i1=floor(((Ymax0-y)/res0));
            j1=floor(((x-Xmin0)/res0));
            if i1>0 && j1>0 && i1<=m0 && j1<=n0
                mat1(i,j,:)=mat0(i1,j1,:);
            end
        end
    end
    return

end