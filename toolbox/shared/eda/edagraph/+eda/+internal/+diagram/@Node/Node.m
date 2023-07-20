classdef(ConstructOnLoad)Node<hgsetget&dynamicprops&matlab.mixin.internal.TreeNode&matlab.mixin.Heterogeneous







    properties
        UniqueName=''
Partition
ChildNode
ChildEdge
Comment
    end

    properties(Dependent,SetAccess=private)
Name
    end

    methods
        function this=Node
            this.Partition.Name='';
            this.Partition.Lang='';
            this.Partition.Type='';
            this.Partition.Board='';
            this.Partition.Comp='';
        end

        function Name=get.Name(this)
            meta=metaclass(this);
            Name=strrep(meta.Name,[meta.ContainingPackage.Name,'.'],'');
        end

        gBuild(this,DUT);
        gUnify(this);
        gCodeGen(this,config);
        cCodeGen(this,config);
        hdlCodeGen(this,config);
        gClear(this,varargin);

        propagateCodeGenProp(this);

        connectPort(this,varargin);
        disConnectComponent(this,property,value,Node);


        assign(this,cmp,rhs);

        comp=component(this,varargin);
        hS=signal(this,varargin);

        hC=findComponent(this,varargin);
        hC=findTreeRoot(this);
        Name=findPort(this,varargin);
        hdl=hdlcodeinit(this);
        lang=findLang(this);
        Name=findSignalName(this,propName,mode);
        Device=getDevice(this,PartInfo);
        [inPutDataWidth,outPutDataWidth]=getIOBitWidth(this,BuildInfo);

        [fileId,fileName]=openFile2W(this,dir,type,Name);

        generateTop(this);
        hdlCodeCleanUp(this,type);
        writeHDLFile(this);
        writeScriptFile(this);
        writePINOUTFile(this);
        writeConstraintFile(this,Board,hC);
    end

end

