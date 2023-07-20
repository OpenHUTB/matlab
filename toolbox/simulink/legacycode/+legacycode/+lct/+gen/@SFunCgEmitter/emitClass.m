



function emitClass(this,codeWriter)



    if this.LctSpecInfo.canUseSFunCgAPI==false
        return
    end


    codeWriter.wNewLine;
    codeWriter.wLine('#if defined(MATLAB_MEX_FILE)');
    codeWriter.wLine('using namespace SFun;');
    codeWriter.wNewLine;
    delim=repmat('=',1,64-length(this.LctSpecInfo.Specs.SFunctionName));
    codeWriter.wMultiCmtStart('Class: %s %s',this.LctSpecInfo.Specs.SFunctionName,delim);
    codeWriter.wMultiCmtMiddle('Abstract:');
    codeWriter.wMultiCmtMiddle('  An instance of this class is called when Simulink Coder is generating');
    codeWriter.wMultiCmtMiddle('  the model.rtw file and the S-Function uses the Code Construction API.');
    codeWriter.wMultiCmtEnd();
    codeWriter.wLine('class %s_Block : public SFun::Block',this.LctSpecInfo.Specs.SFunctionName);
    codeWriter.wLine('{');
    codeWriter.incIndent;




    dimsInfo=iGetNDMatrixDimsInfoProperties(this.LctSpecInfo);


    if~isempty(dimsInfo)
        codeWriter.decIndent;
        codeWriter.wLine('private:');
        codeWriter.incIndent;
        codeWriter.wCmt('Attributes for quicker access to dimension information');
        for ii=1:size(dimsInfo,1)
            cellfun(@(aLine)codeWriter.wLine(aLine),dimsInfo{ii,1});
        end
        codeWriter.wNewLine;
    end


    codeWriter.decIndent;
    codeWriter.wLine('public:');
    codeWriter.incIndent;
    codeWriter.wCmt('Constructor');
    codeWriter.wLine('%s_Block(SFun::SFun_Block_Impl* pImpl) : SFun::Block(pImpl)',this.LctSpecInfo.Specs.SFunctionName);
    codeWriter.wBlockStart();

    if~isempty(dimsInfo)

        for ii=1:size(dimsInfo,1)

            cellfun(@(aLine)codeWriter.wLine(aLine),dimsInfo{ii,2});
        end
    end
    codeWriter.wBlockEnd();


    funInfo={...
    'Start',{'cgStart','Perform initializations on startup'};...
    'InitializeConditions',{'cgInitialize','Perform initializations on startup or subsystem restart'};...
    'Output',{'cgOutput','Compute the signals that this block emits'};...
    'Terminate',{'cgTerminate','Clean up the block on termination'};...
    };


    this.LctSpecInfo.forEachFunction(@(o,k,f)emitMethod(f,k));

    function emitMethod(funSpec,funKind)
        if funSpec.IsSpecified
            idx=find(strcmp(funKind,funInfo(:,1)),1);
            codeWriter.wNewLine;
            codeWriter.wCmt('%s',funInfo{idx,2}{2});
            codeWriter.wLine('virtual void %s()',funInfo{idx,2}{1});
            codeWriter.wBlockStart();
            this.emitMethodBody(codeWriter,funKind);
            codeWriter.wBlockEnd();
        end
    end

    codeWriter.decIndent;
    codeWriter.wLine('};');
    codeWriter.wLine('#endif');

end


function dimsInfo=iGetNDMatrixDimsInfoProperties(lctSpecInfo)



    dimsInfo=cell(0,2);


    varDecl={};
    varInit={};

    function nGetDimsForData(dataSpec)

        varSuffix=dataSpec.Identifier;


        if dataSpec.Width==1||numel(dataSpec.Dimensions)<=2


        else

            numDims=numel(dataSpec.Dimensions);
            varDecl{end+1}=sprintf('DimsInfo_T dimsInfo_%s;',varSuffix);
            varDecl{end+1}=sprintf('int_T dimsArray_%s[%d];',varSuffix,numDims);
            varInit{end+1}=sprintf('dimsInfo_%s.numDims = %d;',varSuffix,numDims);


            apiInfo=legacycode.lct.gen.CodeEmitter.getApiInfo(dataSpec,'cgir');

            if any(dataSpec.Dimensions==-1)


                varInit{end+1}=sprintf('dimsInfo_%s.width = %s;',varSuffix,apiInfo.Width);

                for jj=1:numDims



                    dimStr=legacycode.lct.gen.ExprSFunCgEmitter.emitOneDim(lctSpecInfo,dataSpec,jj);
                    varInit{end+1}=sprintf('dimsArray_%s[%d] = %s;',varSuffix,jj-1,dimStr);%#ok<AGROW>
                end

            else

                varInit{end+1}=sprintf('dimsInfo_%s.width = %d;',varSuffix,dataSpec.Width);
                for jj=1:numDims
                    varInit{end+1}=sprintf('dimsArray_%s[%d] = %d;',varSuffix,jj-1,dataSpec.Dimensions(jj));%#ok<AGROW>
                end
            end

            varInit{end+1}=sprintf('dimsInfo_%s.dims = &dimsArray_%s[0];',varSuffix,varSuffix);


            dimsInfo(end+1,:)={varDecl,varInit};
        end
    end


    lctSpecInfo.forEachDataSetData(@(o,n,s,id,d)visitData(d));

    function visitData(dataSpec)
        nGetDimsForData(dataSpec);
    end
end


