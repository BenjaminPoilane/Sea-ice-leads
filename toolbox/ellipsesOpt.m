function E=ellipsesOpt(K,Pond,tetha,M,l,epaisseur)

% renvoit une image E contenant (seulement) les ellipses d'anisotropie
% correspondant au champ d'anisotropie K, aux directions d'anisotropie
% tetha. 
% l est l'échelle d'analyse en pixel, et épaisseur est l'épaisseur du trait
% des ellipses en pixels.

l=l+(1-mod(l,2));
[m,n]=size(K);
E=zeros(m,n);
Kpond=K.*Pond;

if l==0
    disp('erreur : l=0')
    return
end
if size(tetha)~=size(K)
    disp('dimensions des matrices non coherentes')
    return
end

P=ponder1(K,M);
% Il y aura a x b ellipses dessinées:
a=floor(m/l);
b=floor(n/l);


%On découpe l'image en a x b carrés de coté 2*l, dans chacun desquels on va
%dessiné une ellipse.
for i=1:a
    for j=1:b
% Pour chaque carré, on cherche le point (i0,j0) du sous-carre de cote 2*l/3  et de même centre qui maximise K*Pond         
            iinf=floor(1+(i-1)*l+(l+1)/3);
            isup=floor(1+(i-1)*l+2*(l+1)/3);
            jinf=floor(1+(j-1)*l+(l+1)/3);
            jsup=floor(1+(j-1)*l+2*(l+1)/3);

            [M,imax0]=max(Kpond(iinf:isup,jinf:jsup));
            [M,jmax]=max(M);
            imax=imax0(jmax);
            i0=imax+iinf-1;
            j0=jmax+jinf-1;
            
            if P(i0,j0)>0
% Si le ponderateur en (i0,j0) vaut 1,
%on trace l'ellipse de centre (i0,j0), de grand axe l/3, de petit axe K(i0,j0)*l/3 et de direction theta(i0,j0)                
                if isnan(tetha(i0,j0))==0
                    ux=cos(tetha(i0,j0));
                    uy=sin(tetha(i0,j0));

                    for ep=0:epaisseur-1;
                        E=E+dessinEllipse(E,ux,uy,(l/3)+ep,((1-K(i0,j0))*l/3)+ep,i0,j0);
                    end

                end
            
            end
    end
end
% Il est possible qu'un point est une valeur supérieure à 1, ce dont on ne
% veut pas : 
E=(E>1)+(E<=1).*E;

return 
end
function P=ponder1(K,M)
% Cette fonction renvoit 0 si l'anisotropie es trop faible ou s'il n'y a
% pas assez de données dans le disque d'analyse, et renvoit 1 sinon.
P=(M>1).*(K>0.1);
end
function B=dessinEllipse(A,ux,uy,a,b,x,y) 
% trace une ellipse grand axe selon u=[ux,uy] d'axe a (selon u) et d'axe
% b(selon l'orthogonal de u) et de centre (x,y) sur une matrice de même
% taille que A
    nu=sqrt(ux^2+uy^2);
    u1=ux/nu;
    u2=uy/nu;
    v1=u2;
    v2=-u1;
    B=zeros(size(A));  
    if a*b==0 
        dt=1/max(abs(a),abs(b));
    else
    dt=1/min(abs(a),abs(b));
    end
        for t=0:dt:360
        i=floor(x+a*cos(t)*u1+b*sin(t)*v1);
        j=floor(y+a*cos(t)*u2+b*sin(t)*v2);
        B(i,j)=1;        
        end
    return
    
end