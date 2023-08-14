function update(this,reset)


    this.updateDetails();

    vs=this.propertyValues.toArray;
    this.updateProperties(vs,reset);
    this.current=true;
end