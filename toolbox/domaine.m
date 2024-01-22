function Domaine=domaine(masque,prop,l)
M0=calculDeM0(masque,l);
disque=dessinDisque(l);
aire=sum(sum(disque));
Domaine=(M0>(1-prop)*aire);
end