function generateARStubs(self,pslinkOptions)



    cFile=fullfile(pslinkOptions.cfgDir,['__',self.slModelName,'_pststubs_ar.c']);

    if exist(cFile,'file')
        try
            delete(cFile);
        catch Me %#ok<NASGU>
        end
    end

    fprintf(1,'### %s\n',pslinkprivate('pslinkMessage','get','pslink:generatingStubs'));

    codeBuffer='';

    for ii=1:numel(self.arInfo.fcn)
        fcn=self.arInfo.fcn(ii);


        if isempty(fcn.arg)
            continue
        end


        notFullRange=true;
        hasInDirection=false;
        for jj=1:numel(fcn.arg)
            if~fcn.arg(jj).isStruct
                notFullRange=notFullRange||~fcn.arg(jj).isFullDataTypeRange;
                if~fcn.arg(jj).isFullDataTypeRange
                    [minStr,maxStr]=pslink.util.Helper.getMinMaxStr(fcn.arg(jj).min,fcn.arg(jj).max);
                    notFullRange=notFullRange&&~strcmpi(minStr,'min')&&~strcmpi(maxStr,'max');
                end
            else
                hasFieldNotFullRange=false;


                if~isempty(fcn.arg(jj).field)&&~self.outputFullRange
                    for kk=1:size(fcn.arg(jj).field,1)
                        [minStr,maxStr]=pslink.util.Helper.getMinMaxStr(fcn.arg(jj).field{kk,2}{1},fcn.arg(jj).field{kk,2}{2});
                        hasFieldNotFullRange=hasFieldNotFullRange||(~strcmpi(minStr,'min')&&~strcmpi(maxStr,'max'));
                    end
                end
                notFullRange=hasFieldNotFullRange;
            end
            hasInDirection=hasInDirection||strcmpi(fcn.arg(jj).direction,'in');
        end
        if~notFullRange||~hasInDirection
            continue
        end

        try
            stubbed=nGenerateStub(self.arInfo.fcn(ii));
            self.arInfo.fcn(ii).stubbed=stubbed;
        catch Me %#ok<NASGU>

        end
    end

    if~isempty(codeBuffer)

        [cFid,cErr]=fopen(cFile,'wt','n',self.SourceEncoding);


        if isempty(cErr)
            cleanObj=onCleanup(@()nCleanup(cFid,cFile));

            fprintf(cFid,'/*\n');
            fprintf(cFid,' * File: __%s_pststubs_ar.c\n',self.slModelName);
            fprintf(cFid,' *\n');
            fprintf(cFid,' * C source code generated on : %s\n',datestr(now));
            fprintf(cFid,' */\n\n');



            fprintf(cFid,'/* #ifdef _POLYSPACE_STUB_AUTOSAR_H_ */\n\n');

            fprintf(cFid,'#include "Rte_Type.h"\n');
            fprintf(cFid,'#include "Rte_%s.h"\n',self.arInfo.compName);
            fprintf(cFid,'#include "assert.h"\n\n');

            fprintf(cFid,'%s\n',codeBuffer);

            fprintf(cFid,'/* #endif */\n\n');


            self.stubFile={cFile};

        else
            pslinkprivate('pslinkMessage','warning','pslink:cannotOpenFile',cFile,cErr);
        end
    end

    function stubbed=nGenerateStub(fcn)


        stubbed=false;
        decl='';
        body='';

        if isempty(fcn.return)
            fcnStub='void';
        else
            fcnStub=nGenerateType(fcn.return);
        end

        fcnStub=sprintf('%s %s',fcnStub,fcn.name);
        fcnStub=[fcnStub,'('];

        if isempty(fcn.arg)
            fcnStub=[fcnStub,'void'];
        else

            sep='';
            for zz=1:numel(fcn.arg)
                argName='u';
                if zz>1
                    argName=sprintf('%s%d',argName,zz-1);
                end
                typeName=nGenerateType(fcn.arg(zz));
                fcnStub=sprintf('%s%s%s %s',fcnStub,sep,typeName,argName);
                sep=', ';
            end


            for zz=1:numel(fcn.arg)
                argStr='u';
                if zz>1
                    argStr=sprintf('%s%d',argStr,zz-1);
                end

                if fcn.arg(zz).isPtr
                    if fcn.arg(zz).width<=1||~(pslinkprivate('compareMatlabVersion',8,0)&&self.arInfo.ver(1)=='4')
                        argStr=sprintf('(*%s)',argStr);
                    end
                end

                if fcn.arg(zz).width<=1

                    if~fcn.arg(zz).isStruct
                        if~fcn.arg(zz).isFullDataTypeRange
                            [minVal,maxVal]=pslink.util.Helper.getMinMaxStr(fcn.arg(zz).min,fcn.arg(zz).max);
                            chkStr=nGenerateArgCheck(argStr,minVal,maxVal);
                            if~isempty(chkStr)
                                body=sprintf('%s  assert(%s);\n',...
                                body,chkStr);
                            end
                        end
                    else
                        structType=nFindStructType(fcn.arg(zz).typeName);
                        if isempty(structType)
                            continue
                        end
                        chkStr=nGenerateStructCheck('',structType,argStr,0,'  ');
                        if~isempty(chkStr)
                            body=sprintf('%s%s',body,chkStr);
                        end
                    end
                else

                    argStr=sprintf('%s[i%d]',argStr,zz);
                    if~fcn.arg(zz).isStruct
                        if~fcn.arg(zz).isFullDataTypeRange
                            [minVal,maxVal]=pslink.util.Helper.getMinMaxStr(fcn.arg(zz).min,fcn.arg(zz).max);
                            chkStr=nGenerateArgCheck(argStr,minVal,maxVal);
                            if~isempty(chkStr)
                                decl=sprintf('%s  int i%d;\n',decl,zz);
                                body=sprintf('%s  for(i%d=0; i%d<%d; ++i%d) {\n',...
                                body,zz,zz,fcn.arg(zz).width,zz);
                                body=sprintf('%s    assert(%s);\n  }\n',...
                                body,chkStr);
                            end
                        end
                    else
                        structType=nFindStructType(fcn.arg(zz).typeName);
                        if isempty(structType)
                            continue
                        end
                        chkStr=nGenerateStructCheck('',structType,argStr,0,'  ');
                        if~isempty(chkStr)
                            decl=sprintf('%s  int i%d;\n',decl,zz);
                            body=sprintf('%s  for(i%d=0; i%d<%d; ++i%d) {\n',...
                            body,zz,zz,fcn.arg(zz).width,zz);
                            body=sprintf('%s%s  }\n',body,chkStr);
                        end
                    end
                end
            end
        end

        if~isempty(body)
            fcnStub=[fcnStub,')'];
            codeBuffer=sprintf('%s%s {\n%s\n%s}\n\n',codeBuffer,...
            fcnStub,decl,body);
            stubbed=true;
        end
    end

    function structType=nFindStructType(structName)

        structType=[];
        for pp=1:numel(self.codeInfo.Types)
            if~isa(self.codeInfo.Types(pp),'embedded.structtype')
                continue
            end
            if strcmp(self.codeInfo.Types(pp).Identifier,structName)
                structType=self.codeInfo.Types(pp);
                return
            end
        end
    end

    function chkStr=nGenerateStructCheck(chkStr,structType,parentExpr,depth,extraSpace)


        if nargin<5
            extraSpace='';
        end


        if~isfield(self.drsInfo.busInfo,structType.Identifier)
            return
        end
        busObj=self.drsInfo.busInfo.(structType.Identifier);
        numBusElements=numel(busObj.Elements);

        for pp=1:numel(structType.Elements)

            sE=structType.Elements(pp);
            bE=[];
            if pp<=numBusElements
                bE=busObj.Elements(pp);
                if~strcmp(bE.Name,sE.Identifier)
                    continue
                end
            end

            if~isempty(parentExpr)
                fullExpr=[parentExpr,'.',sE.Identifier];
            else
                fullExpr=sE.Identifier;
            end

            hasLoop=false;
            if sE.Type.getWidth()>1
                hasLoop=true;
                fullExpr=sprintf('%s[i_%d]',fullExpr,depth+1);
            end

            bottomType=pslink.verifier.ec.Coder.getUnderlyingType(sE.Type);
            if isa(bottomType,'embedded.structtype')

                fChkStr=nGenerateStructCheck('',bottomType,fullExpr,depth+1,extraSpace);
            else

                fMinVal=[];
                fMaxVal=[];
                if~isempty(bE)&&isprop(bE,'Min')&&isprop(bE,'Max')
                    fMinVal=bE.Min;
                    fMaxVal=bE.Max;
                end
                minMax=pslink.verifier.ec.Coder.computeDataMinMax([],sE.Type,fMinVal,fMaxVal);
                fChkStr=nGenerateArgCheck(fullExpr,minMax{1},minMax{2});
                if~isempty(fChkStr)
                    incr=depth+1;
                    if hasLoop
                        incr=incr+2;
                    end
                    fChkStr=sprintf('%s%sassert(%s);',extraSpace,nSpace(incr+1),fChkStr);
                end
            end
            if~isempty(fChkStr)
                incr=depth+1;
                if hasLoop


                    chkStr=sprintf('%s%s%s{\n',chkStr,extraSpace,nSpace(incr));
                    incr=incr+1;
                    chkStr=sprintf('%s%s%sint i_%d;\n',chkStr,extraSpace,nSpace(incr),depth+1);
                    chkStr=sprintf('%s%s%sfor(i_%d=0; i_%d<%d; ++i_%d) {\n',...
                    chkStr,extraSpace,nSpace(incr),depth+1,depth+1,sE.Type.getWidth(),depth+1);
                    incr=incr+1;
                end
                chkStr=sprintf('%s%s\n',chkStr,fChkStr);
                if hasLoop

                    incr=incr-1;
                    chkStr=sprintf('%s%s%s}\n',chkStr,extraSpace,nSpace(incr));
                    incr=incr-1;
                    chkStr=sprintf('%s%s%s}\n',chkStr,extraSpace,nSpace(incr));
                end
            end
        end
    end

    function str=nSpace(incr)
        str=repmat('  ',1,incr);
    end

    function chkStr=nGenerateArgCheck(arg,minVal,maxVal)

        chkStr='';
        if~strcmpi(minVal,'min')&&~isempty(minVal)
            if ischar(minVal)
                chkStr=sprintf('%s >= %s',arg,minVal);
            else
                chkStr=sprintf('%s >= %g',arg,minVal);
            end
        end
        if~strcmpi(maxVal,'max')&&~isempty(maxVal)
            if ischar(maxVal)
                str=sprintf('%s <= %s',arg,maxVal);
            else
                str=sprintf('%s <= %g',arg,maxVal);
            end
            if~isempty(chkStr)
                chkStr=sprintf('(%s) && (%s)',chkStr,str);
            else
                chkStr=str;
            end
        end
    end

    function type=nGenerateType(arg)
        type=arg.typeName;
        if arg.width>1&&~(pslinkprivate('compareMatlabVersion',8,0)&&self.arInfo.ver(1)=='4')
            type=sprintf('Rte_rt_Array__%s_%d',arg.typeName,arg.width);
            if numel(type)>self.arInfo.idMaxLength
                try
                    type=arxml.arxml_private(...
                    'p_create_aridentifier',type,...
                    self.arInfo.idMaxLength);
                catch MeType %#ok<NASGU>
                end
            end
        end
        if arg.isPtr
            type=[type,'*'];
        end
    end

    function nCleanup(cFid,filename)

        fclose(cFid);
        if isempty(which('c_beautifier'))==0
            try
                c_beautifier(filename);
            catch Mee %#ok<NASGU>
            end
        end
    end

end



