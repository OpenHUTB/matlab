classdef(CaseInsensitiveProperties,TruncatedProperties)...
    rfbase<hgsetget&matlab.mixin.Copyable&JavaVisible




























    properties(SetAccess=protected,SetObservable)

        Name='';
    end
    methods
        function set.Name(obj,value)
            if~isequal(obj.Name,value)



                obj.Name=value;
            end
        end
    end

    properties(Hidden)

        CopyPropertyObj=true;
    end

    properties(Hidden)

        PropertyChanged=true;
    end

    properties(Hidden)

        Block='';
    end

    methods

        result=checkfrequency(h,freq)
        enum_member=checkenum(h,prop_name,input_str,enum_list,varargin)
        enum_member=checkenumexact(h,prop_name,input_str,enum_list,...
        varargin)


        checkreadonlyproperty(h,varargin_not,names)
        checkproptype(h,value,prop_name,prop_type)
        checkrealscalardouble(h,prop_name,val)
        checkbool(h,prop_name,val)
        h=destroy(h,destroyData)
        disp(h)
        newy=interpolate(h,x,y,newx,method)
        [fname,freq,funit,sfactor]=scalingfrequency(h,in,funit)
        [pname,pdata,punit]=scalingpower(h,in,format,power_type)
        out=setcomplex(h,out,prop,empty_allowed,updateflag,...
        zero_allowed)
        out=setcomplexmatrix(h,out,prop,empty_allowed,updateflag)
        out=setcomplexvector(h,out,prop,empty_allowed,...
        updateflag,zero_allowed)
        out=setintptype(h,out,prop,empty_allowed,updateflag)
        out=setnegativevector(h,out,prop,zero_included,...
        inf_included,empty_allowed,updateflag)
        out=setnetworkparametertype(h,out,prop,empty_allowed,updateflag)
        out=setnoisefigure(h,in,prop,isavector)
        out=setpositive(h,out,prop,zero_included,...
        inf_included,empty_allowed,updateflag)
        out=setpositivevector(h,out,prop,zero_included,...
        inf_included,empty_allowed,updateflag)
        out=setrealvector(h,out,prop,zero_included,...
        inf_included,empty_allowed,updateflag)
    end

    methods(Abstract)

        checkproperty(h)
    end

    methods(Access=protected)
        copyObj=copyElement(h)
    end

end
