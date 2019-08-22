function dotenv( dotenv_file )

fid = fopen(dotenv_file);
tline = fgetl(fid);
while ischar(tline)
    tline = strtrim(tline);
    keys = strsplit(tline, '=');
    setenv( keys{1}, keys{2});
    
    tline = fgetl(fid);
end
fclose(fid);

end
