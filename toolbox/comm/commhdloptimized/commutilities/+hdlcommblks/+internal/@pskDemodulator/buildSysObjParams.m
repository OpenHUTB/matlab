function prm=buildSysObjParams(this,sysObjHandle)%#ok<INUSL>












    if isa(sysObjHandle,'comm.BPSKDemodulator')
        prm=buildPSKparams(sysObjHandle,2);
    elseif isa(sysObjHandle,'comm.QPSKDemodulator')
        prm=buildPSKparams(sysObjHandle,4);
    elseif isa(sysObjHandle,'comm.PSKDemodulator')
        prm=buildPSKparams(sysObjHandle,sysObjHandle.ModulationOrder);
        if isfield(prm,'sinInitPhase')&&~isfield(prm,'sin3Pi8Phase')


            if((abs(prm.phaseOffset-(pi/8)))>abs(prm.phaseOffset-(3*pi/8)))

                prm.isPi8=false;
            else
                prm.isPi8=true;
            end
        end
    end

end


function prm=buildPSKparams(sysObjHandle,M)




    prm=struct;
    prm.M=M;
    prm.phaseOffset=sysObjHandle.PhaseOffset;



    prm.phaseOffset=mod((prm.phaseOffset),2*pi);

    s=sysObjHandle.getAdaptorRunTimeData();
    rtps=s.RTPs;
    rtpsFields=fields(rtps);





    for ii=1:numel(rtpsFields)
        prm.(rtpsFields{ii})=rtps.(rtpsFields{ii});
    end







    if~isfield(prm,'sinInitPhase')

        switch(prm.M)
        case 2
            binedges=[-1,1,3,5,7]*(pi/4);
        case 4
            binedges=[0,1,2,3,4]*(pi/2);
        case 8
            binedges=(0:8)*(pi/4);
        end
        prm.phaseBins=histc(prm.phaseOffset,binedges);
        prm.phaseBins(end)=[];
    end

    if M>2
        prm.isGrayCoded=strcmpi(sysObjHandle.SymbolMapping,'Gray');
    end

end
