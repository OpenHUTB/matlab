classdef NameMap<handle



    properties(Access=private)
BaseNameMap
    end

    methods
        function obj=NameMap
            obj.BaseNameMap=containers.Map;
        end

        function newname=insertName(obj,name)



            hmap=obj.BaseNameMap;

            if isKey(hmap,name)

                nums=hmap(name);
                newnum=numel(nums);

                if newnum==(nums(end)+1)

                    nums=[nums,newnum];
                else
                    if nums(1)

                        newnum=0;
                        nums=[newnum,nums];
                    else

                        newnum=find(diff(nums)-1,1,'first');
                        nums=sort([nums,newnum]);
                    end
                end
            else

                newnum=0;
                nums=newnum;
            end
            hmap(name)=nums;

            if newnum

                newname=sprintf('%s_%d',name,newnum);


                if isKey(hmap,newname)
                    hmap(newname)=[0,hmap(newname)];%#ok<NASGU>
                else
                    hmap(newname)=0;%#ok<NASGU>
                end
            else
                newname=name;


                [isok,bname,bnum]=parseUnderbarName(newname);
                if isok
                    if isKey(hmap,bname)
                        allbnums=hmap(bname);
                        hmap(bname)=sort([bnum,allbnums]);%#ok<NASGU>
                    else
                        hmap(bname)=bnum;%#ok<NASGU>
                    end
                end
            end
        end

        function replaceName(obj,oldname,newname)




            hmap=obj.BaseNameMap;


            if~isKey(hmap,oldname)
                error(message('rf:shared:NamingObjNoSuchName',oldname))
            end
            oldnums=hmap(oldname);
            if oldnums(1)~=0
                error(message('rf:shared:NamingObjNoSuchName',oldname))
            end

            if~strcmp(oldname,newname)

                if isKey(hmap,newname)
                    newnums=hmap(newname);
                    if newnums(1)==0
                        error(message('rf:shared:NamingObjCannotReplace',oldname,newname,newname))
                    end
                end

                removeName(obj,oldname)
                insertName(obj,newname);
            end
        end
    end

    methods(Access=private)
        function removeName(obj,name)

            hmap=obj.BaseNameMap;


            nums=hmap(name);
            nums=nums(2:end);
            if isempty(nums)
                remove(hmap,name);
            else
                hmap(name)=nums;
            end


            [isok,bname,bnum]=parseUnderbarName(name);
            if isok
                nums=hmap(bname);
                nums(nums==bnum)=[];
                if isempty(nums)
                    remove(hmap,bname);
                else
                    hmap(bname)=nums;%#ok<NASGU>
                end
            end
        end
    end

end

function[isok,prestr,postnum]=parseUnderbarName(name)
    isok=false;
    idx=find(name=='_',1,'last');
    if isempty(idx)
        prestr=name;
        postnum=NaN;
    else
        prestr=name(1:(idx-1));
        poststr=name((idx+1):end);
        postnum=str2double(poststr);
        isok=~isnan(postnum)&&strcmp(int2str(postnum),poststr);
    end
end