REBAR := `pwd`/rebar3

all: test release

compile:
	@$(REBAR) compile

doc:
	@$(REBAR) edoc

test:
	@$(REBAR) do xref, dialyzer, eunit, ct, cover

tar:
	@$(REBAR) as prod tar

rpm:
	./rpmbuild.sh

clean:
	@$(REBAR) clean

shell:
	@$(REBAR) shell

.PHONY: release test all compile clean
