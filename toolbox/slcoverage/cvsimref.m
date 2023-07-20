function varargout=cvsimref(modelName,varargin)






















    try
        [status,msgId]=SlCov.CoverageAPI.checkCvLicense;
        if status==0
            error(message(msgId));
        end

        if nargin==0
            error(message('Slvnv:simcoverage:cvsimref:NoInput'))
        end

        modelName=convertStringsToChars(modelName);

        if~ischar(modelName)
            if~ishandle(modelName)
                error(message('Slvnv:simcoverage:cvsimref:FirstInputShouldBeModel'));
            end
            modelName=get_param(modelName,'Name');
        end

        simArgs={};
        testGroups={};
        if~isempty(varargin)
            switch class(varargin{1})
            case 'cv.cvtestgroup'
                for idx=1:length(varargin)
                    if~isa(varargin{idx},'cv.cvtestgroup')
                        simArgs=varargin(idx:end);
                        break;
                    end
                    testGroups{end+1}=varargin{idx};%#ok<AGROW>
                end
            case 'cvtest'
                for idx=1:length(varargin)
                    if~isa(varargin{idx},'cvtest')
                        simArgs=varargin(idx:end);
                        break;
                    end
                    testGroups{end+1}=cv.cvtestgroup(varargin{idx});%#ok<AGROW>
                end
            otherwise
                simArgs={varargin{1:end}};
            end
        end


        testVars=cvtestgroupTocvtest(modelName,testGroups);
        varargout=cell(1,nargout);
        args=[testVars,simArgs];
        [varargout{1:end}]=cvsim(args{:});

    catch MEx
        rethrow(MEx);
    end



    function allTestVars=cvtestgroupTocvtest(topModelName,testGroups)

        allTestVars={};
        if isempty(testGroups)
            cvt=cvtest(topModelName);
            cvt.modelRefSettings.enable='all';
            allTestVars={cvt};
        else
            for idx=1:numel(testGroups)
                cvt=cvtest(topModelName);
                refs=cv.ModelRefData.getMdlReferences(topModelName,true);
                refs=unique(refs);
                cvtg=testGroups{idx};
                cvtgModels=cvtg.allNames;
                for midx=1:numel(cvtgModels)
                    cvtFromTG=cvtg.get(cvtgModels{midx});
                    cvt.emlSettings=mergeSettings(cvt.emlSettings,cvtFromTG.emlSettings);
                    cvt.sfcnSettings=mergeSettings(cvt.sfcnSettings,cvtFromTG.sfcnSettings);
                    cvt.settings=mergeSettings(cvt.settings,cvtFromTG.settings);
                    cvt.options=mergeSettings(cvt.options,cvtFromTG.options);
                end
                cvt.modelRefSettings.excludeTopModel=isempty(intersect({topModelName},cvtgModels));
                eM=setdiff(refs,cvtgModels);
                if isempty(eM)
                    cvt.modelRefSettings.enable='all';
                else
                    excludeModels=eM{1};
                    for eidx=2:numel(eM)
                        excludeModels=[',',eM{eidx}];
                    end
                    if~isempty(excludeModels)
                        cvt.modelRefSettings.excludeModels=excludeModels;
                    end
                end
                if isempty(allTestVars)
                    allTestVars={cvt};
                else
                    allTestVars{end+1}=cvt;%#ok<AGROW>
                end
            end
        end


        function olds=mergeSettings(olds,news)
            fn=fields(olds);
            for idx=1:numel(fn)
                cfn=fn{idx};
                olds.(cfn)=olds.(cfn)||news.(cfn);
            end



