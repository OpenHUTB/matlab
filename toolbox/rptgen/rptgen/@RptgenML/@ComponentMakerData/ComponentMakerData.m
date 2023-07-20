function h=ComponentMakerData(varargin)





    h=feval(mfilename('class'));

    if~isempty(varargin)
        if isstruct(varargin{1})
            h.v1convert(varargin{:});
        elseif isa(varargin{1},'schema.prop')
            p=varargin{1};
            h.PropertyName=p.Name;
            if~isempty(p.Description)
                h.Description=p.Description;
            else

                h.Description=rptgen.prettifyName(p.Name);
            end

            e=findtype(p.DataType);
            if isa(e,'rptgen.enum')
                h.DataTypeString='!ENUMERATION';
                h.EnumValues=strrep(e.Strings,'''','''''');
                h.EnumNames=strrep(e.DisplayNames,'''','''''');
                h.FactoryValueString=RptgenML.toStringExe(p.FactoryValue,'string');
            else
                h.DataTypeString=p.DataType;
                h.FactoryValueString=RptgenML.toStringExe(p.FactoryValue,p.DataType);
            end
        elseif isa(varargin{1},'RptgenML.ComponentMakerData')
            if isLibrary(varargin{1})

                h=copy(varargin{1});
            else


                h=varargin{1};
            end
        else
            set(h,varargin{:});
        end
    end

    h.IsFactoryDefaultValue=true;

