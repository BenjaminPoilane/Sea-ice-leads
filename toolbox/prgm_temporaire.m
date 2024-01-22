moy1=moy;
for(i=1:52)
    for (j=1:size(moy,2))
        moy1(i,j)=moy1(52,j);
    end
end
for(j=1:52)
    for (i=1:size(moy,1))
        moy1(i,j)=moy1(i,52);
    end
end
for(i=size(moy,1)-51:size(moy1,1))
    for(j=1:size(moy,2))
        moy1(i,j)=moy1(size(moy1,1)-51,j);
    end
end
for(j=size(moy,2)-51:size(moy1,2))
    for(i=1:size(moy,1))
        moy1(i,j)=moy1(i,size(moy1,2)-51);
    end
end