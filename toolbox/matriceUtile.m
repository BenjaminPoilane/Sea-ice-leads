function [imin,imax,jmin,jmax]=matriceUtile(M0)
M=double(M0);
[n,m]=size(M);
i=0;
imin=n;
jmin=m;
imax=n;
jmax=m;
while i<=n-1
    j=0;
    i=i+1;
        while j<=m-1
            j=j+1;
            if M(i,j)>0
                imin=i;
                i=n+1;
                j=m+1;
            end
        end
end
j=0;
while j<=m-1
    i=0;
    j=j+1;
        while i<=n-1
            i=i+1;
            if M(i,j)>0
                jmin=j;
                i=n+1;
                j=m+1;
            end
        end
end

j=m+1;
while j>1
    i=n+1;
    j=j-1;
        while i>1
            i=i-1;
            if M(i,j)>0
                jmax=j;
                i=0;
                j=0;
            end
        end
end

i=n+1;

while i>1
    j=m+1;
    i=i-1;
        while j>1
            j=j-1;
            if M(i,j)>0
                imax=i;
                i=0;
                j=0;
            end
        end
end


return;






end