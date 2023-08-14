function propValue=isReadonlyProperty(this,propName)%#ok





    if~isempty(strfind(this.parentnode.Name,'mat'))...
        ||strcmpi(this.parentnode.Name,'HitCache')...
        ||strcmpi(this.parentnode.Name,'MissCache')...
        ||~isempty(strfind(this.parentnode.Name,'.p'))

        propValue=true;
    else

        propValue=false;
    end