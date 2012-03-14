function [] = Tecplot()
%u = (2/pi)*(1/sqrt(x^2+y^2))*cos(atan(y/x));
%v = (2/pi)*(1/sqrt(x^2+y^2))*sin(atan(y/x));

imax=26;
jmax=51;
gridx = zeros(imax,jmax);
gridy = zeros(imax,jmax);

%grid=0.02*i-0.02;
%gridy=0.02j-0.02;

%%Open Data File for Writing
fid=fopen('Data_2Blocks.dat','w');

%%Print File Headers
fprintf(fid,'title = "Driven Cavity"\r\n');
fprintf(fid,'variables = "x", "y", "u", "v"\r\n');

%%Print Block Header
fprintf(fid,'ZONE T = "All"\r\n');
fprintf(fid,' I='); fprintf(fid, '%i',imax);
fprintf(fid,' J='); fprintf(fid, '%i',jmax);
fprintf(fid,' K=1');
fprintf(fid,' ZONETYPE=Ordered\r\n');
fprintf(fid,' DATAPACKING=POINT\r\n');

i=0;
j=0;
%%Print Data
for i=1:imax
    %grid=0.02*i-0.02;
    %gridy=0.02*jmax-0.02;
       for j=1:jmax
           gridy(i,j) = gridy(i,j)+j*.02;
           fprintf(fid,'%f',gridx(i,j));
           fprintf(fid,'\t');
           fprintf(fid,'%f',gridy(i,j));
           fprintf(fid,'\t');
           %fprintf(fid,'%f',u(i,j));
           %fprintf(fid,'\t');
           %fprintf(fid,'%f',v(i,j));
           fprintf(fid,'\r\n');
       end
end

%Close File
fclose(fid);
fclose all
end
%{
%%%%%%%%%%%%
%%2 Blocks%%
%%%%%%%%%%%%

yhalf=(jmax-1)/2+1;

%%Open Data File for Writing
fid=fopen('Data_2Blocks.dat','w');

%%Print File Headers
fprintf(fid,'title = "Driven Cavity"\r\n');
fprintf(fid,'variables = "x", "y", "u", "v"\r\n');

%%Print Block Header (1)
fprintf(fid,'ZONE T="Subzone 1"\r\n');
fprintf(fid,' I=');fprintf(fid,'%i',yhalf);
fprintf(fid,' J=');fprintf(fid,'%i',jmax);
fprintf(fid,' K=1');
fprintf(fid,' ZONETYPE=Ordered\r\n');
fprintf(fid,' DATAPACKING=POINT\r\n');

%%Print Data for Block 1
for i=1:imax
    for j=1:yhalf
        fprintf(fid,'%f',gridx(i,j));
        fprintf(fid,'\t');
        fprintf(fid,'%f',gridy(i,j));
        fprintf(fid,'\t');
        fprintf(fid,'%f',u(i,j));
        fprintf(fid,'\t');
        fprintf(fid,'%f',v(i,j));
        fprintf(fid,'\r\n');
    end
end

%%Print Block Header (2)
fprintf(fid,'ZONE T="Subzone 2"\r\n');
fprintf(fid,' I=');fprintf(fid,'%i',yhalf);
fprintf(fid,' J=');fprintf(fid,'%i',jmax);
fprintf(fid,' K=1');
fprintf(fid,' ZONETYPE=Ordered\r\n');
fprintf(fid,' DATAPACKING=POINT\r\n');

%%Print Data for Block 2
for i=1:imax
    for j=yhalf:jmax
        fprintf(fid,'%f',gridx(i,j));
        fprintf(fid,'\t');
        fprintf(fid,'%f',gridy(i,j));
        fprintf(fid,'\t');
        fprintf(fid,'%f',u(i,j));
        fprintf(fid,'\t');
        fprintf(fid,'%f',v(i,j));
        fprintf(fid,'\r\n');
    end
end

%%Close File
fclose(fid);
%}
