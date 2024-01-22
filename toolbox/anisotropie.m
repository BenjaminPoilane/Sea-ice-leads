function [K1,pond1,M01,angles1]=anisotropie(MatriceDesDonnees,Masque,scalePix)
% Methode qui prend en entree un matrice de donnees (image matricielle), un
% masque de meme format que la matrice des donnes (1 lorsqu'il y a des
% donnes 0 sinon), et une echelle d'analyse en pixels: scalePix


% Il faut que l'echelle en pixel (maintenant appelée 'l' ) soit impaire : 
l=scalePix+(1-mod(scalePix,2)); 



% On calcul les indices [imin, imax, jmin, jmax] tels que tous les coeffs
% non nuls de la matrice des donnees soient compris dans ces indices
[imin,imax,jmin,jmax]=matriceUtile(Masque.*MatriceDesDonnees>0);

% Pour gagner du temps, on n'appliquera la methode qu'à la matrice extraite
% de 'MatriceDesDonnes' comprise entre [imin-l, jmin-l, imax+l, jmax+l].
% On completera avec des zeros ensuite.
imin=max(1,imin-l);
imax=min(size(MatriceDesDonnees,1),imax+l);
jmin=max(1,jmin-l);
jmax=min(size(MatriceDesDonnees,2),jmax+l);
M=double(MatriceDesDonnees(imin:imax,jmin:jmax));
[n,m]=size(M);

% INITIALISATION DES SORTIES :

K=zeros(n,m);           % K matrice des valeurs d'anisotropie
M0=zeros(n,m);          % M0(i,j) est la somme des coeffs de M compris dans le disque d'analyse centré en (i,j) de diamètre l.
pond=zeros(n,m);        % pond(i,j)=M0(i,j)/l si M0<l, 1 sinon. Utile pour l'affichage des ellipses.
angles=NaN+zeros(n,m);  % directions principales d'anisotropie (en radian)

% indices du centre du premier disque d'analyse 
i0=(l+1)/2;
j0=(l+1)/2;

contd=contourCirculaire(l,'droite'); % Limite à droite du disque d'analyse
contg=contourCirculaire(l,'gauche'); % Limite à gauche du disque d'analyse
conth=contourCirculaire(l,'haut');   % Limite en haut du disque d'analyse
contb=contourCirculaire(l,'bas');    % Limite en bas du disque d'analyse

% direction est la direction de progression du disque. Initialisee à [0,1],
% meme ligne, une colonne en plus, c'est-à-dire vers la droite.
direction=[0,1];
memoireDirection=[0,1];

%contour qui sera perdu lorsque le disque d'analyse va avancé:
contPrec=contg;

%contour qui vient d'être gagné lorsque le disuqe d'analyse à avancé:
contSuiv=contd;

% Les mab (ou a,b= 0,1,2 ) sont des coeffs qui servent à calculer les
% coeffs de la matrice d'inertie du disque d'analyse.
% mab= Somme pour (i,j) dans le disque des M(i,j)*(i-i0)^a * (j-j0)^b 
% où i0,j0 sont les coordonnées du centre du disque.

m0=0;
m10=0;
m01=0;
m11=0;
m20=0;
m02=0;

% Initialisation des ces coeffs pour le premier disque d'analyse:

for i=1:l
    for j=1:l
        if (i-i0)^2+(j-j0)^2<=(l/2)^2
            m0=m0+M(i,j);
            m10=m10+(i-i0)*M(i,j);
            m01=m01+(j-j0)*M(i,j);
            m11=m11+(i-i0)*(j-j0)*M(i,j);
            m20=m20+(i-i0)*(i-i0)*M(i,j);
            m02=m02+(j-j0)^2*M(i,j);
        end
    end
end



% Début du parcours de l'image par le disque d'analyse
while i0+j0<n+m-2*(l-1)/2
   
   
% Définition de contPrec et contSuiv de la prochaine iteration en fonction de la direction d'avancement du disque    
    
% Si la direction va vers la droite ([0,1]) ou vers la gauche ([0,-1]):    
    if direction(2)==1
        contPrec=contg;
        contSuiv=contd;
    end
    if direction(2)==-1
        contPrec=contd;
        contSuiv=contg;
    end
    
    
% Si la direction est vers le bas, l'avancement va se faire soit vers la
% gauche, soit vers la droite en fonction de l'avancement d'avant
% (memoireDirection)
    if direction(1)==1
disp(i0);
        if memoireDirection(2)==1
            direction=[0,-1];
            contPrec=contd;
            contSuiv=contg;
        end
        if memoireDirection(2)==-1
            direction=[0,1];
            contPrec=contg;
            contSuiv=contd;
        end
        memoireDirection=direction;
    end
    
% Si on est en bout de ligne :     
    if direction(2)==1 && j0+(l-1)/2>=m
        memoireDirection=direction;
        direction=[1,0]; 
        contPrec=conth;
        contSuiv=contb;
    end
    if direction(2)==-1 && j0-(l-1)/2<=1
        memoireDirection=direction;
        direction=[1,0];
        contPrec=conth;
        contSuiv=contb;
    end
    
    
% passage de l'expression des mab exprimés en fonction de (i0,j0) à
% (i0,j0)+direction
    
    m11= m11 - direction(1)*m01 - direction(2)*m10;
    m20= m20 + abs(direction(1))*m0 - 2*direction(1)*m10;
    m02= m02 + abs(direction(2))*m0 - direction(2)*2*m01;
    m10= m10 - direction(1)*m0;
    m01= m01 - direction(2)*m0;
    
% on fait avancer (i0,j0)
    i0=i0+direction(1);
    j0=j0+direction(2);

% On retire les contributions de contPrec
    m0=m0-somme1(contPrec,M,0,0,i0,j0);
    m10=m10-somme1(contPrec,M,1,0,i0,j0);
    m01=m01-somme1(contPrec,M,0,1,i0,j0);
    m20=m20-somme1(contPrec,M,2,0,i0,j0);
    m02=m02-somme1(contPrec,M,0,2,i0,j0);
    m11=m11-somme1(contPrec,M,1,1,i0,j0);
    
% On met à jour les contours du disque d'analyse :   
    contg(:,1)=contg(:,1)+direction(1);
    contd(:,1)=contd(:,1)+direction(1);
    conth(:,1)=conth(:,1)+direction(1);
    contb(:,1)=contb(:,1)+direction(1);
    contg(:,2)=contg(:,2)+direction(2);
    contd(:,2)=contd(:,2)+direction(2);
    conth(:,2)=conth(:,2)+direction(2);
    contb(:,2)=contb(:,2)+direction(2);
    
% On met à jour contSuiv:    
    contSuiv(:,1)=contSuiv(:,1)+direction(1);
    contSuiv(:,2)=contSuiv(:,2)+direction(2);

% On rajoute aux mab la contribution de contSuiv   
    m0=m0+somme1(contSuiv,M,0,0,i0,j0);
    m10=m10+somme1(contSuiv,M,1,0,i0,j0);
    m01=m01+somme1(contSuiv,M,0,1,i0,j0);
    m20=m20+somme1(contSuiv,M,2,0,i0,j0);
    m02=m02+somme1(contSuiv,M,0,2,i0,j0);
    m11=m11+somme1(contSuiv,M,1,1,i0,j0);

    M0(i0,j0)=m0;
    
% On va maintenant calculer la matrice d'inertie = [a,c ; c,b] et ses
% valeurs propres: l1 et l2 (l1 < l2)
    
    if m0<=l*10^-5
% Si m0 est trop faible, on considere qu'il n'y a que du bruit dans le
% disque d'analyse, et on considere que le champ est nul, donc matrice
% d'inertie nulle, avec une anisotropie nulle.
        l1=1;
        l2=1;
        a=0;
        b=0;
        c=0;
        
        
    else
% Sinon, on calcule a, et b a partir des mab        
        a= max(m20-(m10*m10)/m0,0);
        b= max(m02-(m01*m01)/m0,0);
        
        if a==0 || b==0
% Si a et b sont nul, c est nécessairement nul:            
            c=0;
        else
% Sinon, calcul de c à partir des mab            
            c= m11-(m10*m01)/m0 ;
        end
        
        if a*b-c^2<0
% Si le determinant est négatif (theoretiquement impossible), on ajuste c pour que le determinant soit nul            
            c=sign(c)*sqrt(a*b);
        end
        
        if a<=l^2*10^-7 && b<=l^2*10^-7     
%si a et b sont presque nuls, on met tout à 0 et on met une anisotropie nulle (l2=1, l1=1), l'angle vaudra 0
            a=0;
            b=0;
            c=0;
            l1=1;
            l2=1;
        else
% Sinon, calcul des valeurs propres:            
            [l1,l2]=valeuresPropres(a,b,c);     
            if abs(a*b-c^2)<10^-5               % si le det est presque nul (i.e une vp est presque nulle), on met l1 à 0 (pour éviter l1<0)
                l1=0;                           
            end
        end        
        
    end
    
   
   K(i0,j0)=1-(l1/l2);
   
   pond(i0,j0)=ponder(m0,l);
   angles(i0,j0)=anglePrinc(a,b,c,l2);
    
end

% On complete maintenant nos matrices par des zeros pour avoir la meme
% taille que MatriceDesDonnees:

K1=zeros(size(MatriceDesDonnees));
pond1=zeros(size(MatriceDesDonnees));
angles1=zeros(size(MatriceDesDonnees))+NaN;

M01=zeros(size(MatriceDesDonnees));

K1(imin:imax,jmin:jmax)=K;
pond1(imin:imax,jmin:jmax)=pond;

angles1(imin:imax,jmin:jmax)=angles;
M01(imin:imax,jmin:jmax)=M0;

return;
end
function tot=somme1(c,M,expi,expj,i0,j0)
% Calcul somme des M(i,j)*(i-i0)^expi * (j-j0)^expj où les valeurs de i et
% j sont données par c ( liste des i: c(:,1); liste des j: c(:,2) )

    s=size(c);
    tot=0;
    for k=1:s(1)
        tot=tot+M(c(k,1),c(k,2))*((c(k,1)-i0)^expi)*((c(k,2)-j0)^expj);
    end
    return
end

function [lambd1,lambd2]=valeuresPropres(a,b,c)
%Calcul les valeurs propres de la matrice [a,c ; c,b]
lambd1=(a+b-sqrt((a-b)^2+4*c^2))/2;
lambd2=(a+b+sqrt((a-b)^2+4*c^2))/2;
return
end
function tetha=anglePrinc(a,b,c,lambdMax)
% Calcul l'angle de la direction du vecteur propre associé à la plus grande
% valeur propre. 0 si les valeurs propres sont égales.
if abs(c)>0.001
    x=(lambdMax-b)/c;
    x=x/sqrt(x^2+1);
    tetha=acos(x);
else
    if abs(b)>abs(c)
        tetha=pi/2;
    else
        tetha=0;
    end
end
return
end
function p=ponder(m,l)
% Calcul le ponderateur
    if m<l
        p=m/l;
    else
        p=1;
    end
    return
end

