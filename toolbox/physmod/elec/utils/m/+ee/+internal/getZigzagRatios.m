function x=getZigzagRatios(phaseShift)%#codegen





    absphi=abs(phaseShift);
    x=[cos(absphi)-1/sqrt(3)*sin(absphi),2/sqrt(3)*sin(absphi)];

    x(1)=x(1)+(x(1)==0)*eps;
    x(2)=x(2)+(x(2)==0)*eps;

end