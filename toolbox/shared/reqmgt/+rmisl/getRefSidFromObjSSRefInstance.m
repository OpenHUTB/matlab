function refSid=getRefSidFromObjSSRefInstance(objH,isSf,doesConsiderTop)

    if nargin<3
        doesConsiderTop=false;
    end
    if nargin<2||isempty(isSf)
        [isSf,objH,errMsg]=rmi.resolveobj(objH);
        if~isempty(errMsg)
            error(message('Simulink:util:ErrorOfExecutingCommand','rmi.resolveobj()',errMsg));
        end

        if isSf
            doesConsiderTop=false;
        end
    end

    if isSf
        if isa(objH,'double')

            objId=objH;
            sr=sfroot;
            objH=sr.idToHandle(objH);
            sidInMain=Simulink.ID.getSID(objH);
        else
            [~,objId]=rmi.resolveobj(objH);
            if ischar(objH)

                sidInMain=objH;
            else
                sidInMain=Simulink.ID.getSID(objH);
            end
        end

        if isempty(objId)

            refSid='';
            return;
        end

        chartPath=rmisf.sfinstance(objId);
        chartSidInMain=Simulink.ID.getSID(chartPath);
        chartSidInSSR=slInternal('getSourceBlockFromSSRefInstanceBlock',chartPath);
        refSid=strrep(sidInMain,chartSidInMain,chartSidInSSR);
    else
        refSid=slInternal('getSourceBlockFromSSRefInstanceBlock',objH);
        if isempty(refSid)&&doesConsiderTop
            try
                refSid=get_param(objH,'ReferencedSubsystem');
            catch ex %#ok<NASGU>

            end
        end
    end

    if isempty(refSid)
        refSid='';
    end
end


