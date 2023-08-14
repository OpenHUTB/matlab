function[shortDesc,longDesc,dataType]=getRefentryInfo(this)




    shortDesc=this.DescriptionShort;
    longDesc=this.DescriptionLong;
    dataType=this.DataType;

    if isempty(shortDesc)
        tType=getTransformType(this);
        if~isempty(tType)
            sr=RptgenML.StylesheetRoot;
            if isempty(sr.(['Params',tType]))


            else
                paramLib=sr.getParamsLibrary(tType);
                libElement=find(paramLib,'ID',this.ID);
                if~isempty(libElement)
                    libElement=libElement(1);
                    shortDesc=libElement.DescriptionShort;
                    longDesc=libElement.DescriptionLong;
                    dataType=libElement.DataType;

                    this.DescriptionShort=shortDesc;
                    this.DescriptionLong=longDesc;
                    this.DataType=dataType;
                else


                end
            end
        end
    end





    function tType=getTransformType(this)

        tType='';

        this=this.up;
        while~isempty(this)
            if isa(this,'RptgenML.StylesheetEditor')
                tType=this.TransformType;
            elseif isa(this,'RptgenML.LibraryCategory')
                return;
            end
            this=this.up;
        end