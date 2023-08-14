



classdef HandwrittenFEHandler<internal.cxxfe.FrontEndHandler
    properties

        SFcnMessages=struct('kind',{},...
        'file',{},...
        'line',{},...
        'desc',{},...
        'detail',{})


        InstrumentedLocations=struct('file',{},...
        'start',{},...
        'end',{},...
        'paramStart',{},...
        'paramEnd',{},...
        'wrapperName',{},...
        'type',{});
    end
    methods(Access=public)

        function afterParsing(obj,ilPtr,~,~,~)
            handwritten_sldv_sfcn_mex(ilPtr,obj);
        end

        function addSFcnWarning(obj,msgId,file,line,~,varargin)
            descMsg=message('sldv_sfcn:sldv_sfcn:compatibilityWarning');
            desc=descMsg.getString();

            detailMsg=message(msgId,varargin{:});
            detail=detailMsg.getString();

            obj.SFcnMessages(end+1)=struct('kind','warning',...
            'file',file,...
            'line',line,...
            'desc',desc,...
            'detail',detail);
        end




        function addInstrumentedLocation(obj,file,wrapperName,type,...
            startLine,startCol,endLine,endCol,...
            startParamL,startParamC,endParamL,endParamC)
            startPos=[startLine,startCol];
            endPos=[endLine,endCol];
            startParam=[startParamL,startParamC];
            endParam=[endParamL,endParamC];
            obj.InstrumentedLocations(end+1)=struct('file',file,...
            'start',startPos,...
            'end',endPos,...
            'paramStart',startParam,...
            'paramEnd',endParam,...
            'wrapperName',wrapperName,...
            'type',type);
        end
    end

    methods(Static=true)
        function stubsFile=getDefaultStubsFile()
            stubsFile=fullfile(matlabroot,'toolbox','shared','sldv_cc','sldv_cc',...
            '+sldv','+code','+sfcn','+internal','simstruc.stubs');
        end
        function stubsInfo=readStubsFile(fileName)
            parser=matlab.io.xml.dom.Parser;
            xmlData=parser.parseFile(fileName);

            macroElements=xmlData.getElementsByTagName('macro');
            stubCount=macroElements.getLength();
            stubsInfo(1:stubCount)=struct('Name','',...
            'Args','',...
            'RetType','',...
            'Body','',...
            'AddedIn','',...
            'RemovedIn','',...
            'Excluded',false);

            minReleaseAttribute='addedIn';
            maxReleaseAttribute='removedIn';
            excludedAttribute='excluded';
            for ii=1:stubCount
                current=macroElements.item(ii-1);

                stubsInfo(ii).Name=current.getAttribute('name');
                stubsInfo(ii).Args=current.getAttribute('argList');
                stubsInfo(ii).RetType=current.getAttribute('retType');
                stubsInfo(ii).MinRelease='';
                stubsInfo(ii).MaxRelease='';
                stubsInfo(ii).Excluded=false;


                if current.hasAttribute(minReleaseAttribute)
                    stubsInfo(ii).MinRelease=current.getAttribute(minReleaseAttribute);
                end
                if current.hasAttribute(maxReleaseAttribute)
                    stubsInfo(ii).MaxRelease=current.getAttribute(maxReleaseAttribute);
                end

                if current.hasAttribute(excludedAttribute)
                    excludedStr=current.getAttribute(excludedAttribute);
                    if strcmpi(excludedStr,'true')
                        stubsInfo(ii).Excluded=true;
                    end
                end

                bodyElements=current.getElementsByTagName('body');
                if bodyElements.getLength()==1
                    body=bodyElements.item(0);
                    stubsInfo(ii).Body=body.getTextContent();
                end
            end
        end

        function wrappedMacros=generateWrapperHeaders(includeDir)
            stubsFile=sldv.code.sfcn.internal.HandwrittenFEHandler.getDefaultStubsFile();
            stubsInfo=sldv.code.sfcn.internal.HandwrittenFEHandler.readStubsFile(stubsFile);

            sourceEncoding=matlab.internal.i18n.locale.default.Encoding;


            copyfile(fullfile(matlabroot,'simulink','include','simstruc.h'),...
            fullfile(includeDir,'real_simstruc.h'),'f');
            fid=fopen(fullfile(includeDir,'simstruc.h'),'w','n',sourceEncoding);
            fprintf(fid,['#ifndef __MW_WRAPPER_SIMSTRUC_H__\n',...
            '#define __MW_WRAPPER_SIMSTRUC_H__\n',...
            '#include "real_simstruc.h"\n\n']);


            fprintf(fid,'#ifdef __cplusplus\n');
            fprintf(fid,'extern "C" {\n');
            fprintf(fid,'#endif /* __cplusplus */\n');


            wrappedMacros=cell(1,numel(stubsInfo));
            for m=1:numel(stubsInfo)
                stub=stubsInfo(m);

                if~stub.Excluded

                    macro=stub.Name;

                    wrappedMacros{m}=macro;

                    fprintf(fid,'#undef %s\n',macro);
                    fprintf(fid,'extern %s %s(%s);\n\n',stub.RetType,macro,stub.Args);
                end
            end




            for m={...
                'mwSize mxGetNumberOfElements(const mxArray *a)',...
                'mwSize mxGetNumberOfDimensions(const mxArray *a)',...
                'mwSize mxGetN(const mxArray *a)',...
                'mwSize mxGetM(const mxArray *a)',...
                'double mxGetScalar(const mxArray *a)',...
                'void *mxGetData(const mxArray *a)',...
                'double *mxGetPr(const mxArray *a)',...
                'mwSize *mxGetDimensions(const mxArray *a)',...
                }
                signature=m{1};

                token=regexpi(signature,'(\w*)\s*\(','tokens');
                macro=token{1}{1};

                fprintf(fid,'#ifdef %s\n',macro);
                fprintf(fid,'#undef %s\n',macro);
                fprintf(fid,'extern %s;\n\n',signature);
                fprintf(fid,'#endif\n');
            end

            fprintf(fid,'#ifdef __cplusplus\n');
            fprintf(fid,'}\n');
            fprintf(fid,'#endif /* __cplusplus */\n');

            fprintf(fid,'#endif /* __MW_WRAPPER_SIMSTRUC_H__*/\n');
            fclose(fid);





            fid=fopen(fullfile(includeDir,'simulink.c'),'w','n',sourceEncoding);
            fprintf(fid,'/* Empty file */\n');



            fclose(fid);


            fid=fopen(fullfile(includeDir,'cg_sfun.h'),'w','n',sourceEncoding);
            fprintf(fid,'/* Empty file */\n');
            fclose(fid);
        end
    end
end


