function cgirComp=getBitConcatComp(hN,hInSignals,hOutSignals,compName)












    if numel(hInSignals)==1&&hdlissignalscalar(hInSignals)


        if(nargin<4)
            compName=[hInSignals(1).Name,'_wire'];
        end
        desc='';
        slHandle=-1;
        cgirComp=pircore.getWireComp(hN,hInSignals,hOutSignals,compName,desc,slHandle);
    else
        if(nargin<4)
            compName='concat';
        end
        cgirComp=pircore.getBitConcatComp(hN,hInSignals,hOutSignals,compName);
    end

end

