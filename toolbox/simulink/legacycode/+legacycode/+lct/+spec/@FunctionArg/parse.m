



function parse(this)


    defObj=legacycode.lct.spec.Common.instance();


    argSpecPos=regexpi(this.Expression,defObj.ArgSpecExpr,'tokenExtents');




    if isempty(argSpecPos)||~isnumeric(argSpecPos{1})||~ismember(size(argSpecPos{1},1),[2,3])
        throw(legacycode.lct.spec.ParseException('LCTSpecParserBadArgExpr',...
        this.Expression,this.PosOffset));
    end



    argSpecPos=argSpecPos{1};
    this.SpecPos(1,:)=argSpecPos(1,:);



    if size(argSpecPos,1)==2

        this.SpecPos(5,:)=argSpecPos(2,:);


        this.extractExprArgSpec();
    else
        if strcmpi(this.TypeExpr,'void')

            this.SpecPos(2:3,:)=argSpecPos(2:3,:);


            this.extractVoidArgSpec();
        else

            this.SpecPos(3:4,:)=argSpecPos(2:3,:);


            this.extractArgSpec();
        end
    end
