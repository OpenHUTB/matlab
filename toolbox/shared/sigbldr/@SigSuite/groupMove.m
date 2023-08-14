








function groupMove(this,index1,index2,varargin)

    if index1>index2

        b=index2:this.NumGroups;



        c=b(b~=index1);


        this.Groups=[this.Groups(1:index2-1),this.Groups(index1),this.Groups(c)];

    elseif index2>index1

        b=1:index2;



        c=b(1:index2~=index1);


        this.Groups=[this.Groups(c),this.Groups(index1),this.Groups(index2+1:end)];

    else

    end
end