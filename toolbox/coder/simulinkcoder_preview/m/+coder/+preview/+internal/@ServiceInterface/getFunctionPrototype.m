function out=getFunctionPrototype(~,returnType,name,arg)





    mf0=mf.zero.Model;
    prototype=coder.descriptor.types.Prototype(mf0);


    prototype.Return=coder.descriptor.types.Argument(mf0);
    prototype.Return.Type=coder.descriptor.types.Type(mf0);
    prototype.Return.Type.Identifier=returnType;


    prototype.Name=name;


    if nargin>=4
        prototype.Arguments.add(coder.descriptor.types.Argument(mf0));
        prototype.Arguments(1).Type=coder.descriptor.types.Type;
        prototype.Arguments(1).Type.Identifier=arg{1};
        prototype.Arguments(1).Name=arg{2};
    end


    descriptor=coder.codedescriptor.CodeDescriptor('');

    out=descriptor.getServiceFunctionDeclaration(prototype);
