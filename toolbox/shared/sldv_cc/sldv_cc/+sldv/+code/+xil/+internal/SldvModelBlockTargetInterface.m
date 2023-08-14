classdef(Hidden=true)SldvModelBlockTargetInterface<rtw.pil.ModelBlockTargetInterface&sldv.code.xil.internal.SldvTargetInterface








    methods



        function this=SldvModelBlockTargetInterface(silPILWrapperUtils,targetInterfacePath)
            narginchk(2,2);

            this@rtw.pil.ModelBlockTargetInterface(silPILWrapperUtils,...
            targetInterfacePath);
        end
    end

    methods(Access='public',Hidden)



        function varargout=callProtectedMethod(this,methodName,varargin)
            [varargout{1:nargout}]=feval(methodName,this,varargin{:});
        end
    end

    methods(Access='protected')




        function out=getCodeInfoUtilsObj(this)
            out=this.codeInfoUtils;
        end




        function out=getWriterObj(this)
            out=this.writer;
        end




        function out=getSILPILWrapperUtilsObj(this)
            out=this.SILPILWrapperUtils;
        end




        function out=isProfilingEnabled(~)
            out=false;
        end




        function writeOutputBody(this)
            writeOutputBody@rtw.pil.ModelBlockTargetInterface(this);
            this.emitSectionWrapperInit();
            this.emitSectionWrapperStep();
            this.emitSectionMain();
            this.emitSectionTrailer();
        end




        function writeSectionHeader(this)
            this.emitSectionHeader(this.writerOutputPath,this.codeInfo.Name);
        end




        function writeSectionIncludes(this)
            this.emitSectionIncludes();
            writeSectionIncludes@rtw.pil.ModelBlockTargetInterface(this);
        end




        function writeSectionStorageForData(this,dataInterfaces,varargin)
            writeSectionStorageForData@rtw.pil.ModelBlockTargetInterface(this,dataInterfaces,varargin{:});
            this.emitSectionStorageForData(dataInterfaces,varargin);
        end




        function writeSectionDefinesMatFileLogging(~)
        end




        function writeSectionOutputBodyMatFileLogging(~)
        end




        function writeSectionTerminateMatFileLogging(~)
        end




        function writeSectionXILIOData(this)%#ok<MANU>
        end




        function writeSectionGetDataTypeInfo(~)
        end




        function writeSectionInitUDataProcessing(~)
        end




        function writeSectionUploadProfilingDataPoint(~)
        end




        function writeSectionInitSDataProcessing(~)
        end




        function writeSectionInitYDataProcessing(~)
        end




        function writeSectionPause(~)
        end




        function writeSectionOutputOutputAssignments(~,~)
        end




        function writeOutputAssignments(~,~)
        end





        function writeInputAssignments(~,~)
        end
    end
end


