function [M1]=passage(M,Xm0,XM0,Ym0,YM0,Xm1,XM1,Ym1,YM1,res)
[m0,n0]=size(M);
m1= floor((YM1-Ym1)/res)+1;
n1= floor((XM1-Xm1)/res)+1;
YM1=Ym1 + m1*res;
XM1=Xm1 + n1*res;


if size(M,3)==1
    M1=zeros(m1,n1);
elseif size(M,3)==3
    M1=zeros(m1,n1,3);
end
jmin1=max(1,1+round( (Xm0-Xm1)/res ) );
jmin0=max(1,1+round( (Xm1-Xm0)/res ) );

imin1=max(1,1+round( (YM1-YM0)/res ) );
imin0=max(1,1+round( (YM0-YM1)/res ) );

nint=round( (min(XM1,XM0)-max(Xm1,Xm0))/res );
mint=round( (min(YM1,YM0)-max(Ym1,Ym0))/res );


M1(imin1:imin1+mint-1,jmin1:jmin1+nint -1,: ) =M(imin0:imin0+mint-1,jmin0:jmin0+nint-1,:);
return;

end