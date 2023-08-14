classdef(ConstructOnLoad)Component<eda.internal.diagram.Node








    properties
HDL
InstName
        HDLFiles={};
HDLFileDir
        NetList={};
NetListDir
        Script={};
ScriptDir
SimModel
SimScript
SynScript
        SynConstraintFile={};
    end

    methods
        function this=Component(varargin)
            this.HDL=this.hdlcodeinit;
            if~isempty(varargin)
                arg=this.componentArg(varargin);
                componentSet(this,arg)
            end
        end

    end

    methods
        hdlcode=componentDecl(this,varargin);
        hdlcode=componentInst(this);
        hdlcode=hdlsignalDecl(this);
        hdlcode=entityDecl(this,generic_decl);
        hdlcode=inithdlcodeinit(this);
        hdlcode=componentBody(this)
        arg=componentArg(varargin);
        componentInit(varargin);
        componentSet(varargin);
        setGenerics(varargin);
        value=getGenericInstanceValue(this,generic);
        hdlType=findhdltype(this,fitype);
    end

end

