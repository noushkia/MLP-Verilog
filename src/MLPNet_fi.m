w1 = importdata('./Input and Parameters/w1_sm.dat',',',0);
w2 = importdata('./Input and Parameters/w2_sm.dat',',',0);
b1 = importdata('./Input and Parameters/b1_sm.dat',',',0);
b2 = importdata('./Input and Parameters/b2_sm.dat',',',0);

te_data = importdata('./Input and Parameters/te_data_sm.dat',',',0);
te_label = importdata('./Input and Parameters/te_label_sm.dat',',',0);

wl=8;
w_f=0; 
T=numerictype(1,wl,w_f);
F=fimath('RoundMode','floor',...
         'OverflowMode','Saturate',...
         'ProductMode','SpecifyPrecision',...
         'ProductWordLength',wl,...
         'ProductFractionLength',w_f,...
         'SumMode','KeepLSB',...
         'SumWordLength',wl,...
         'SumFractionLength',w_f);
         
w1=fi(w1,T,F);
w2=fi(w2,T,F);
b1=fi(b1,T,F);
b2=fi(b2,T,F);

te_data = fi(te_data,T,F);

fd = fopen('./hex_data_matlab/w1.hex','w');
fprintf(fd,'16''h%c%c%c%c\n',hex(reshape(w1, size(w1,1)*size(w1,2),1))');
fclose(fd);

fd = fopen('./hex_data_matlab/w2.hex','w');
fprintf(fd,'16''h%c%c%c%c\n',hex(reshape(w2, size(w2,1)*size(w2,2),1))');
fclose(fd);

fd = fopen('./hex_data_matlab/b1.hex','w');
fprintf(fd,'16''h%c%c%c%c\n',hex(b1)');
fclose(fd);

fd = fopen('./hex_data_matlab/b2.hex','w');
fprintf(fd,'16''h%c%c%c%c\n',hex(b2)');
fclose(fd);


fd = fopen('./hex_data_matlab/te_data.hex','w');
fprintf(fd,'16''h%c%c%c%c\n',hex(reshape(te_data' , size(te_data,1)*size(te_data,2),1) )');
fclose(fd);

sl = [size(w1,1) size(w2,1) size(w2,2)];
y_pred = fi(zeros(size(te_label)),T,F);
Q = 100;
for q=1:Q%size(te_data,1)
    q
    x = te_data(q,:)';
    
    z1 = fi(zeros(sl(2),1),T,F);
    a1 = fi(zeros(sl(2),1),T,F);
    for i=1:sl(2)
        for j = 1:sl(1)
            z1(i) = z1(i) + w1(j,i)*x(j);
        end
        z1(i) = z1(i) + b1(i);
        if z1(i) < 0
            a1(i) = 0;
        else
            a1(i) = z1(i);
        end
    end

    z2 = fi(zeros(sl(2),1),T,F);
    a2 = fi(zeros(sl(2),1),T,F);

    for i=1:sl(3)
        for j = 1:sl(2)
            z2(i) = z2(i) + w2(j,i)*a1(j);
        end
        z2(i) = z2(i) + b2(i);
        if z2(i) < 0
            a2(i) = 0;
        else
            a2(i) = z2(i);
        end
    end
    
    s = find(a2 == max(a2));
        
    y_pred(q,1) = s(1)-1;
    
    
end

fd = fopen('./fixed_data/te_label_pred.dat','w');
for i=1:size(te_data,1)
    fprintf(fd,'%f,',double(y_pred(i,:)));
    fprintf(fd, '\n');
end
fclose(fd);

ccr = sum(te_label(1:Q) == y_pred(1:Q))/Q;
disp(ccr*100);
