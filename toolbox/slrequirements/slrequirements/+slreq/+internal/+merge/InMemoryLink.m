

classdef InMemoryLink<handle


    properties(Constant)
        KeyFormat='yyyy-mm-ddTHH:MM:ss';
    end
    properties(SetAccess=immutable)
        Key(1,:)char{mustBeNonempty}=' ';
        CreatedOnNum(1,1)double{mustBeReal}=0;
        CreatedBy(1,:)char{mustBeNonempty}=' ';
        ModifiedOnNum(1,1)double{mustBeReal}=0;
        ModifiedBy(1,:)char{mustBeNonempty}=' ';
        Revision(1,1)int32{mustBeInteger,mustBePositive}=1;
    end
    properties

        Type(1,:)char;
        Description(:,:)char;
        Keywords(1,:);
        Rationale(:,:)char;
        Source(1,1)struct{mustBeNonempty};
        Destination(1,1)struct{mustBeNonempty};
    end


    methods



        function this=InMemoryLink(aLink)
            import slreq.internal.merge.*;


            this.Type=aLink.Type;
            this.Description=aLink.Description;
            this.Rationale=aLink.Rationale;
            this.Keywords=aLink.Keywords;
            this.CreatedBy=aLink.CreatedBy;
            this.CreatedOnNum=datenum(aLink.CreatedOn);
            this.ModifiedBy=aLink.ModifiedBy;
            this.ModifiedOnNum=datenum(aLink.ModifiedOn);
            this.Revision=aLink.Revision;

            this.Source=aLink.source();

            if isfield(this.Source,'artifact')&&~ispc
                this.Source.artifact=strrep(this.Source.artifact,'\','/');
            end
            this.Destination=aLink.getReferenceInfo();


            this.Key=InMemoryLink.generateKey(aLink);
        end





        function result=findEdits(this,that)

            result=containers.Map('KeyType','char','ValueType','any');

            if~strcmp(this.Type,that.Type)
                result("Type")=that.Type;
            end

            if~strcmp(this.Description,that.Description)
                result("Description")=that.Description;
            end

            if~strcmp(this.Rationale,that.Rationale)
                result("Rationale")=that.Rationale;
            end

            if~isequal(this.Keywords,that.Keywords)
                result("Keywords")=that.Keywords;
            end

            if~isequal(this.Source,that.Source)
                result("Source")=that.Source;
            end

            if~isequal(this.Destination,that.Destination)
                result("Destination")=that.Destination;
            end









        end

    end


    methods(Static)




        function Key=generateKey(aLink)
            import slreq.internal.merge.*;

            timepart=datestr(aLink.CreatedOn,InMemoryLink.KeyFormat);
            Key=[timepart,':',aLink.CreatedBy];

        end





        function tf=isModified(thisLink,thatLink)


            assert((thisLink.CreatedOnNum==thatLink.CreatedOnNum)&&...
            strcmp(thisLink.CreatedBy,thatLink.CreatedBy));

            tf=(thisLink.Revision~=thatLink.Revision)||...
            (thisLink.ModifiedOnNum~=thatLink.ModifiedOnNum)||...
            ~strcmp(thisLink.ModifiedBy,thatLink.ModifiedBy);

        end

    end
end


