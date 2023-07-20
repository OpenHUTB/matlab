function jOutputFormat=getFormat(this,fmt)




    if nargin<2
        fmt=this.Format;
    end

    if rptgen.use_java
        fmtCls='com.mathworks.toolbox.rptgencore.output.OutputFormat';
    else
        fmtCls='rptgen.internal.output.OutputFormat';
    end

    if isa(fmt,fmtCls)
        jOutputFormat=fmt;
    else

        if rptgen.use_java
            shouldGetFormat=isempty(this.FormatObject)||...
            ~this.FormatObject.getID.equalsIgnoreCase(fmt);
        else
            shouldGetFormat=isempty(this.FormatObject)||...
            ~(this.FormatObject.getID()==string(fmt));
        end
        if shouldGetFormat
            if rptgen.use_java
                jOutputFormat=com.mathworks.toolbox.rptgencore.output.OutputFormat.getFormat(fmt);
            else
                jOutputFormat=rptgen.internal.output.OutputFormat.getFormat(fmt);
            end
            if nargin<2
                this.FormatObject=jOutputFormat;
            end
        else
            jOutputFormat=this.FormatObject;
        end
    end

