



function resObj=performOp(resObj1,resObj2,opKind,clsName)

    narginchk(3,4);

    if nargin<4
        clsName='codeinstrum.internal.codecov.CodeCovData';
    else
        validateattributes(clsName,{'char'},{'nrows',1});
    end


    if isempty(resObj1)
        resObj1=feval(clsName,'traceabilitydbfile','');
    end
    if isempty(resObj2)
        resObj2=feval(clsName,'traceabilitydbfile','');
    end

    validateattributes(resObj1,{clsName},{'scalar'});
    validateattributes(resObj2,{clsName},{'scalar'});
    validatestring(opKind,{'+','-','*'});


    if~hasResults(resObj1)||~hasResults(resObj2)
        resObj=feval([clsName,'.empty']);
        if opKind=='+'
            if~hasResults(resObj1)&&hasResults(resObj2)
                resObj=clone(resObj2);
            elseif hasResults(resObj1)&&~hasResults(resObj2)
                resObj=clone(resObj1);
            end

        elseif opKind=='-'
            if~hasResults(resObj1)&&hasResults(resObj2)
                resObj=clone(resObj2,true);
            elseif hasResults(resObj1)&&~hasResults(resObj2)
                resObj=clone(resObj1);
            end
        end
        return
    end

    resObj=resObj1.clone(true);
    resObj.CodeCovDataImpl=internal.codecov.CodeCovData.performOp(resObj1.CodeCovDataImpl,resObj2.CodeCovDataImpl,opKind);

    if opKind=='+'
        sid=resObj.getInstanceSIDs();
        sid1=resObj1.getInstanceSIDs();
        [~,idx]=ismember(sid1,sid);
        for ii=1:numel(sid1)
            if idx(ii)~=0
                htmlFile=resObj1.getHtmlFile(ii);
                if~isempty(htmlFile)
                    resObj.setHtmlFile(idx(ii),htmlFile);
                end
            end
        end
        sid2=resObj2.getInstanceSIDs();
        [~,idx]=ismember(sid2,sid);
        for ii=1:numel(sid2)
            if idx(ii)~=0
                htmlFile=resObj2.getHtmlFile(ii);
                if~isempty(htmlFile)
                    resObj.setHtmlFile(idx(ii),htmlFile);
                end
            end
        end
    end

end
