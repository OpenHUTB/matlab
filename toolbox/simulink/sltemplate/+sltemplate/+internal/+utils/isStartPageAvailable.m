function flag=isStartPageAvailable

    flag=~isempty(getenv('Decaf'))||usejava('jvm');
end
