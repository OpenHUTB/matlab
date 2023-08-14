


classdef(Sealed)AsicfpgaWrapGenSb<hdlwfsmartbuild.WrapGenBase


    methods(Access=private)
        function obj=AsicfpgaWrapGenSb(hDI)
            obj=obj@hdlwfsmartbuild.WrapGenBase(hDI);
        end
    end


    methods(Static)
        function singleObj=getInstance(hDI)
            hdlWFSbMap=hDI.gethdlWFSbMap;
            if isKey(hdlWFSbMap,'asicfpgaWrapGenSb')
                existObj=hdlWFSbMap('asicfpgaWrapGenSb');
                if isempty(existObj)||~isvalid(existObj)

                    singleObj=hdlwfsmartbuild.AsicfpgaWrapGenSb(hDI);

                    hDI.addhdlWFSbMap('asicfpgaWrapGenSb',singleObj);
                else

                    singleObj=existObj;
                end
            else

                singleObj=hdlwfsmartbuild.AsicfpgaWrapGenSb(hDI);

                hDI.addhdlWFSbMap('asicfpgaWrapGenSb',singleObj);
            end
        end
    end


    methods(Access=public)

        function depInforStr=getDepInforStr(this)
            targetMap=containers.Map('KeyType','char','ValueType','any');
            this.setTargetMap(targetMap);
            depInforStr=hdlwfsmartbuild.serialize(targetMap);
        end


        function preprocess(this)


            this.cmpsaveDUTChecksum;

            this.DepCkList=struct('ChecksumName',{},'FileName',{});
            depCKFieldname='dutChecksum';
            depcksbStatusFileFullName=fullfile(getProp(this.hDI.hCodeGen.hCHandle.getINI,'codegendir'),this.hDI.hCodeGen.ModelName,this.SBSTATUSFILENAME);
            this.addintoDepCkList(depCKFieldname,depcksbStatusFileFullName);

            ckFieldName='wrapperChecksum';
            cksbStatusFileFullName=fullfile(getProp(this.hDI.hCodeGen.hCHandle.getINI,'codegendir'),this.hDI.hCodeGen.ModelName,this.SBSTATUSFILENAME);
            this.createMatfileContent(ckFieldName,cksbStatusFileFullName,'wrapperGenLog',cksbStatusFileFullName);

            this.calculateNewChecksum;
            this.clearMatfileContentInFile;

        end

        function postprocess(this)




            this.updateLog('');
            this.saveNewMatfileContentInFile;

        end

    end
end

