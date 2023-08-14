








































classdef UtilConfiguration<handle
    properties(Access=private)

        fEDGOptions=[];


        fProperties=[];
    end

    methods(Access=public,Hidden=true)

        function aObj=UtilConfiguration(varargin)
            aObj.fProperties=slci.common.ObjectProp;


            aObj.setVerbose(false);
            aObj.setUtilVerbose(false);
            aObj.setTargetLangSuffix('.c');
            aObj.setTargetUtilsFile('');
            aObj.setBaselineUtilsFile('');


            default='';
            validationFcn=@(x)assert(ischar(x)||iscellstr(x)||isstring(x));

            p=inputParser();
            paramName='BaselineUtilsFolder';
            p.addParameter(paramName,default,validationFcn);

            paramName='TargetUtilsFolder';
            p.addParameter(paramName,default,validationFcn);

            p.parse(varargin{:});

            res=p.Results;
            aObj.setBaselineUtilsFolder(res.BaselineUtilsFolder);
            aObj.setTargetUtilsFolder(res.TargetUtilsFolder);

        end


        function out=getEDGOptions(aObj)
            out={aObj.fEDGOptions};
        end


        function setVerbose(aObj,aVerbose)
            if islogical(aVerbose)
                aObj.fProperties.setProperty('Verbose',aVerbose);
            else
                DAStudio.error('Slci:slci:VerboseMustBeLogical')
            end
        end


        function out=getVerbose(aObj)
            out=aObj.fProperties.getProperty('Verbose');
        end


        function setUtilVerbose(aObj,aVerbose)
            if islogical(aVerbose)
                aObj.fProperties.setProperty('UtilVerbose',aVerbose);
            else
                DAStudio.error('Slci:slci:VerboseMustBeLogical')
            end
        end


        function out=getUtilVerbose(aObj)
            out=aObj.fProperties.getProperty('UtilVerbose');
        end


        function setTargetUtilsFolder(aObj,afolder)
            aObj.fProperties.setProperty('TargetUtilsFolder',afolder);
        end


        function out=getTargetUtilsFolder(aObj)
            out=aObj.fProperties.getProperty('TargetUtilsFolder');
        end


        function setBaselineUtilsFolder(aObj,afolder)
            aObj.fProperties.setProperty('BaselineUtilsFolder',afolder);
        end


        function out=getBaselineUtilsFolder(aObj)
            out=aObj.fProperties.getProperty('BaselineUtilsFolder');
        end


        function setTargetUtilsFile(aObj,afile)
            aObj.fProperties.setProperty('TargetUtilsFile',afile);
        end


        function out=getTargetUtilsFile(aObj)
            out=aObj.fProperties.getProperty('TargetUtilsFile');
        end


        function setBaselineUtilsFile(aObj,afile)
            aObj.fProperties.setProperty('BaselineUtilsFile',afile);
        end


        function out=getBaselineUtilsFile(aObj)
            out=aObj.fProperties.getProperty('BaselineUtilsFile');
        end


        function setTargetLangSuffix(aObj,aSuffix)

            if(strcmpi(aSuffix,'.c')||strcmpi(aSuffix,'.cpp'));
                aObj.fProperties.setProperty('TargetLangSuffix',aSuffix);
            else
                DAStudio.error('Slci:slci:TargetLangSuffix')
            end
        end


        function out=getTargetLangSuffix(aObj)
            out=aObj.fProperties.getProperty('TargetLangSuffix');
        end


        function setVerificationResult(aObj,aVResult)
            aObj.fProperties.setProperty('VerificationResult',aVResult);
        end








        function out=getVerificationResult(aObj)
            out=aObj.fProperties.getProperty('VerificationResult');
        end

        inspectResults=inspect(aObj,varargin);
    end

    methods(Access=private)
        HandleException(aObj,aException)


        function setDefaultEDGOptions(aObj)
            aEDGOptions=internal.cxxfe.FrontEndOptions;
            aEDGOptions.KeepRedundantCasts=1;
            aObj.fEDGOptions=aEDGOptions;
        end
    end
end
