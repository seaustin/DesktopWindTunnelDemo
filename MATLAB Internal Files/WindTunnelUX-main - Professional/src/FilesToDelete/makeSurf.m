[x, y, z] = LookupTable();

fs = 12;
mk = '.';

dataFig = figure(1);
splot = surf(x, y, z, 'FaceAlpha', 1.0);
light
lighting gouraud
xlabel("$\alpha$-port $\Delta P$ (Pa)", Interpreter="latex", FontSize=fs)
ylabel("Dynamic Pressure (Pa)", Interpreter="latex", FontSize=fs)
zlabel("Angle of Attack ($^\circ$)", Interpreter="latex", FontSize=fs)
axis tight
grid on
view(60, 50)

xh = get(gca,'XLabel'); % Handle of the x label
set(xh, 'Units', 'Normalized')
pos = get(xh, 'Position');
set(xh, 'Position',pos.*[.7,-1,1],'Rotation',-40)
yh = get(gca,'YLabel'); % Handle of the y label
set(yh, 'Units', 'Normalized')
pos = get(yh, 'Position');
set(yh, 'Position',pos.*[1,0,1],'Rotation',15)

set(splot, "AmbientStrength", .6)