function [t,angles]=roseDesDirections(nbParts,theta,pond)
% renvoit une liste de 10 000 angles des valeurs dans (k*2*Pi/nbParts pour
% k=0:nbParts-1), correspondant à la repartition des angles de direction
% principale pondérés par un pondérateur pond (l'anisotropie en pratique).
%(attention, ce 'pond' n'a rien à voir avec le 'pond' calculé dans la
% méthode anisotropie)

% Il suffit ensuite d'effectuer 'rose(angles,t)' pour avoir l'image de la
% rose des directions

dt=2*pi/nbParts;
t=0:1:nbParts-1;
t=t*dt;
r=zeros(1,nbParts);
for i=1:size(theta,1)
    for j=1:size(theta,2)
        if isnan(theta(i,j))==0
            i0=1+mod(floor(0.5+(theta(i,j)/dt)),nbParts);
            i1=1+mod(floor(0.5+((theta(i,j)+pi)/dt)),nbParts);
            r(i0)=r(i0)+pond(i,j);
            r(i1)=r(i1)+pond(i,j);
        end
    end
end
total=(sum(r));
angles=zeros(1,10000);
imax=floor(10000*r(1)/total);
angles(1:imax)=t(1);
for i=2:nbParts
    imin=imax+1;
    imax=floor(10000*sum(r(1:i)/total));
    angles(imin:imax)=t(i);
end
angles=angles-pi/2;
t=t-(pi)/2;
return
end