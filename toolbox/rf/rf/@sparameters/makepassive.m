function passive_sobj=makepassive(sobj)




    narginchk(1,1)

    passive_data=makepassive(sobj.Parameters);
    passive_sobj=sparameters(passive_data,sobj.Frequencies,sobj.Impedance);