function F=frontiere(L)
[n,m]=size(L);
F=L;

for i=2:n-1
    for j=2:m-1
        if L(i+1,j)~=0 && L(i,j+1)~=0 && L(i-1,j)~=0 && L(i,j-1)~=0
            F(i,j)=0;
        end
    end
end
return






end