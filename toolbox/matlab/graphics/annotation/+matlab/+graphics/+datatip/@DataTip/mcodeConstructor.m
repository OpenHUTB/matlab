function mcodeConstructor(this,code)










    setConstructorName(code,'datatip');

    hTarget=this.Parent;
    arg=codegen.codeargument('IsParameter',true,'Name','object','Value',hTarget);
    localGenerateCommentedCode(this,code,hTarget);

    addConstructorArgin(code,arg);
    propsToAdd={};
    if strcmpi(this.SnapToDataVertex,'off')
        propsToIgnore={'Parent','X','Y','Z','Content','SelectionHighlight','Tag'};
    else
        propsToIgnore={'Parent','X','Y','Z','Content','SelectionHighlight','Tag','SnapToDataVertex','InterpolationFactor'};
    end
    ignoreProperty(code,propsToIgnore);
    addProperty(code,propsToAdd);

    generateDefaultPropValueSyntax(code);
end

function[x,y,z]=localGenerateCommentedCode(this,code,hTarget)
    x=this.X;
    y=this.Y;
    z=this.Z;

    if(~iscategorical(x)&&~isnumeric(x))||...
        (~iscategorical(y)&&~isnumeric(y))||...
        (~iscategorical(z)&&~isnumeric(z))
        return;
    end
    if iscategorical(x)
        x=string(x);
    end

    if iscategorical(y)
        y=string(y);
    end

    if iscategorical(z)
        z=string(z);
    end


    hTargetArg=codegen.codeargument('Value',hTarget,'IsParameter',true);
    code.addPreConstructorFunction(codegen.codetext(['% ',getString(...
    message('MATLAB:graphics:datatip:UncommentLineToCreateDataTip'))]));
    hArg1=codegen.codeargument('Value',x);
    hArg2=codegen.codeargument('Value',y);

    ax=ancestor(hTarget,'axes');
    if~isempty(ax)&&~is2D(ax)
        hArg3=codegen.codeargument('Value',z);
        code.addPreConstructorFunction(codegen.codetext('% datatip(',hTargetArg,',',hArg1,',',hArg2,',',hArg3,');'));
    else
        code.addPreConstructorFunction(codegen.codetext('% datatip(',hTargetArg,',',hArg1,',',hArg2,');'));
    end
end