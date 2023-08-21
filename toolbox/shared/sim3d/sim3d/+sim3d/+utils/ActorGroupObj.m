classdef ActorGroupObj<handle

    properties
ActorType
Actors
LastActor
    end
    methods

        function obj=ActorGroupObj(ActorType)
            obj.ActorType=ActorType;
            obj.LastActor=sim3d.utils.Actors.empty;
            obj.Actors=containers.Map;
        end


        function addNewActor(obj,blk,pCustom)

            if isempty(obj.LastActor)
                ID=1;
                ActorTag=[obj.ActorType,num2str(ID)];
                if~isempty(pCustom)
                    while isKey(pCustom.Actors,ActorTag)
                        ID=ID+1;
                        ActorTag=[obj.ActorType,num2str(ID)];
                    end
                end
                newActor=sim3d.utils.Actors(ID,obj.LastActor,sim3d.utils.Actors.empty,blk,ActorTag);
            else
                ID=obj.LastActor.ID+1;
                ActorTag=[obj.ActorType,num2str(ID)];
                if~isempty(pCustom)
                    while isKey(pCustom.Actors,ActorTag)
                        ID=ID+1;
                        ActorTag=[obj.ActorType,num2str(ID)];
                    end
                end
                newActor=sim3d.utils.Actors(ID,obj.LastActor,sim3d.utils.Actors.empty,blk,ActorTag);
                Prev=obj.LastActor;
                Prev.Next=newActor;
            end

            obj.Actors(ActorTag)=newActor;
            obj.LastActor=newActor;
        end


        function addCustomActor(obj,blk,ActorTag)
            if isempty(obj.LastActor)
                newActor=sim3d.utils.Actors(1,obj.LastActor,sim3d.utils.Actors.empty,blk,ActorTag);
                obj.Actors(ActorTag)=newActor;
                obj.LastActor=newActor;
            elseif~obj.existBlk(ActorTag,blk)
                newActor=sim3d.utils.Actors(obj.LastActor.ID+1,obj.LastActor,sim3d.utils.Actors.empty,blk,ActorTag);
                Prev=obj.LastActor;
                Prev.Next=newActor;
                obj.Actors(ActorTag)=newActor;
                obj.LastActor=newActor;
            end
        end


        function addActor(obj,blk,ID)

            if ischar(ID)
                ID=uint8(str2double(ID));
            end
            nprev=ID-1;
            nnext=ID+1;
            ActorTag=[obj.ActorType,num2str(ID)];
            obj.Actors(ActorTag)=sim3d.utils.Actors(ID,sim3d.utils.Actors.empty,sim3d.utils.Actors.empty,blk,ActorTag);
            curActor=obj.Actors(ActorTag);
            while nprev>0
                if isKey(obj.Actors,[obj.ActorType,num2str(nprev)])
                    curActor.Prev=obj.Actors([obj.ActorType,num2str(nprev)]);
                    Prev=curActor.Prev;
                    Prev.Next=obj.Actors([obj.ActorType,num2str(ID)]);
                    break
                end
                nprev=nprev-1;
            end
            if~isempty(obj.LastActor)
                if ID>obj.LastActor.ID
                    obj.LastActor.Next=obj.Actors([obj.ActorType,num2str(ID)]);
                    obj.LastActor=obj.Actors([obj.ActorType,num2str(ID)]);
                else
                    while nnext<=obj.LastActor.ID
                        if isKey(obj.Actors,[obj.ActorType,num2str(nnext)])
                            curActor.Next=obj.Actors([obj.ActorType,num2str(nnext)]);
                            Next=curActor.Next;
                            Next.Prev=curActor;
                            break
                        end
                        nnext=nnext+1;
                    end
                end
            else
                obj.LastActor=obj.Actors([obj.ActorType,num2str(ID)]);
            end
        end


        function out=removeCustomActor(obj,ActorTag)
            currActor=obj.LastActor;
            out=false;
            while~isempty(currActor)
                if strcmp(currActor.ActorTag,ActorTag)
                    obj.removeActor(currActor.ActorTag);
                    out=true;
                end
                currActor=currActor.Prev;
            end
        end


        function out=removeActor(obj,ActorTag)
            if~isKey(obj.Actors,ActorTag)
                out=false;
            else
                if strcmp(ActorTag,num2str(obj.LastActor.ActorTag))
                    obj.LastActor=obj.LastActor.Prev;
                end
                Cur=obj.Actors(ActorTag);
                if~isempty(Cur.Prev)
                    Cur.Prev.Next=Cur.Next;
                end
                if~isempty(Cur.Next)
                    Cur.Next.Prev=Cur.Prev;
                end
                remove(obj.Actors,ActorTag);
                out=true;
            end
        end


        function out=exist(obj,ActorTag,Blk)

            out=false;
            if isKey(obj.Actors,ActorTag)
                currActor=obj.Actors(ActorTag);
                if~strcmp(currActor.Blk,Blk)
                    out=true;
                end
            end
        end


        function out=existBlk(obj,ActorTag,Blk)

            out=false;
            if isKey(obj.Actors,ActorTag)
                currActor=obj.Actors(ActorTag);
                if strcmp(currActor.Blk,Blk)
                    out=true;
                end
            end
        end
    end
end
