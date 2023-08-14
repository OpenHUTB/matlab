function GUID=guidGet(obj,rawreqs,modelH)



    if nargin<2
        [isSf,objH,~]=rmi.resolveobj(obj);
        rawreqs=rmi.getRawReqs(objH,isSf);
    else
        objH=obj;
        isSf=floor(obj)==obj;
    end


    GUID='';
    if nargin<2&&ischar(rawreqs)
        GUID=reqmgt('guidGet',rawreqs);
    end

    if isempty(GUID)

        if nargin<3
            modelH=rmisl.getmodelh(objH);
        end


        isLocked=~rmisl.isUnlocked(modelH,0);
        if isLocked
            if Simulink.harness.internal.hasActiveHarness(modelH)



                Simulink.harness.internal.setBDLock(modelH,false);
            else

                isLibrary=strcmpi(get_param(modelH,'BlockDiagramType'),'library');
                if isLibrary
                    return;
                end
            end
        end

        GUIDStr=net.jini.id.UuidFactory.generate();
        GUIDStr=char(GUIDStr.toString());
        GUIDRawStr=strrep(GUIDStr,'-','_');
        GUID=['GIDa_',GUIDRawStr];


        if isempty(rawreqs)
            rawreqs='{} ';
        end
        rawreqs=[rawreqs,' %',GUID];
        rmi.setRawReqs(objH,isSf,rawreqs,modelH);


        guidtable=get_param(modelH,'GUIDTable');
        if isempty(guidtable)
            guidtable=reqmgt('guidBuild',modelH);
        end
        if isempty(guidtable)
            guidtable=struct(GUID,objH);
        else
            guidtable.(GUID)=objH;
        end
        set_param(modelH,'guidtable',guidtable);

        if isLocked
            Simulink.harness.internal.setBDLock(modelH,true);
        end
    end



