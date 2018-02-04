.PHONY: all fig build vim clean

all:  build

build: 
	mkdir -p obj
	mkdir -p obj/src
	if [ -e obj/main.aux ];\
	then\
		cp obj/main.aux obj/main_old.aux;\
	fi
	pdflatex -jobname embHw -output-directory obj main.tex
	#cd obj && bibtex lightcom.aux
	latex_count=5 ; \
	while ! cmp -s obj/main.aux obj/main_old.aux && [ $$latex_count -gt 0 ] ;\
	do \
		echo "Rerunning latex....." ;\
		cp obj/main.aux obj/main_old.aux;\
		pdflatex -jobname embHw -output-directory obj main.tex ;\
		latex_count=`expr $$latex_count - 1` ;\
	done

clean:
	rm -f obj/*.aux
	rm -f obj/src/*.aux
	rm -f obj/*.bbl
	rm -f obj/*.blg
	rm -f obj/*.lof
	rm -f obj/*.log
	rm -f obj/*.lot
	rm -f obj/*.out
	rm -f obj/*.tdo
	rm -f obj/*.toc
