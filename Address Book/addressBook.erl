%% @author Karol Kozak
%% @doc @todo Add description to addressBook.

-module(addressBook).
-export([createAddressBook/0, addContact/3, addEmail/4, addPhone/4, addCompanyName/4, addCompanyNamePosition/4, removeContact/3, 
		 removeEmail/2, removePhone/2, getEmails/3, getPhones/3, findByEmail/2, findByPhone/2, findWorkers/2]).
-import(lists, [filter/2]).
-import(io, [format/1]).
-import(string, [concat/2]).

-record(addressBook, {name, surname, phoneNumber, email, companyName, position}).

createAddressBook() -> [].

addContact(Name, Surname, AB) ->
	case getContact(AB, Name, Surname) of
		[_]  -> format("Kontakt juz istnieje!");
		[] -> [#addressBook{name=Name, surname=Surname}|AB]
	end.

addEmail(Name, Surname, Email, AB) ->
	Addresses = getOthers(AB, Name, Surname),
	case getContactByEmail(Email, AB) of
		[_]  -> format("Kontakt juz istnieje!"); %%znalazl kontakt po mailu, nie mozna dodac
		[] -> 										%%nie znalazl po mailu => szukamy po nazwisku
			case getContact(AB, Name, Surname) of
				[U] -> [U#addressBook{email=Email}|Addresses];
				[] -> [#addressBook{name=Name, surname=Surname, email=Email}|Addresses]
			end
	end.

addPhone(Name, Surname, PhoneNumber, AB) ->	
	Addresses = getOthers(AB, Name, Surname),									%%wybieram te, których nie chcemy ew zmodyfikować
	case getContactByPhoneNumber(PhoneNumber, AB) of
		[_]  -> format("Kontakt juz istnieje!"); 				%%znalazl kontakt po mailu, nie mozna dodac
		[] -> 
			case getContact(AB, Name, Surname) of									%%wybieramy pasujący element lub jego brak
				[U]  -> [U#addressBook{phoneNumber=PhoneNumber}|Addresses];			%%istnial, aktualizujemy
				[] -> [#addressBook{name=Name, surname=Surname, phoneNumber=PhoneNumber}|Addresses]%%dodajemy nowy
			end
	end.

addCompanyName(Name, Surname, CompanyName, AB) ->
	Addresses = getOthers(AB, Name, Surname),
	case getContact(AB, Name, Surname) of
		[U]  -> [U#addressBook{companyName=CompanyName}|Addresses];
		[] -> [#addressBook{name=Name, surname=Surname, companyName=CompanyName}|Addresses]
	end.

addCompanyNamePosition(Name, Surname, Position, AB) ->
	Addresses = getOthers(AB, Name, Surname),
	case getContact(AB, Name, Surname) of
		[U]  -> [U#addressBook{position=Position}|Addresses];
		[] -> [#addressBook{name=Name, surname=Surname, position=Position}|Addresses]
	end.

removeContact(Name, Surname, AB) -> 
	getOthers(AB, Name, Surname).

removeEmail(Email, AB) ->
	Addresses = getOthersByEmail(Email, AB),
	U = hd(getContactByEmail(Email, AB)),					%%getContactByEmail() zwraca listę z jednym elementem, wyciągamy go z listy
	[U#addressBook{email=undefined}|Addresses].
	
removePhone(PhoneNumber, AB) ->
	Addresses = getOthersByPhoneNumber(PhoneNumber, AB),
	U = hd(getContactByPhoneNumber(PhoneNumber, AB)),		%%zwraca listę z jednym elementem, wyciągamy go z listy
	[U#addressBook{phoneNumber=undefined}|Addresses].

getEmails(Name, Surname, AB) ->
	[X#addressBook.email || X<-getContact(AB, Name, Surname)].

getPhones(Name, Surname, AB) ->
	[X#addressBook.phoneNumber || X<-getContact(AB, Name, Surname)].

findByEmail(Email, AB) ->
	U = hd(getContactByEmail(Email, AB)),
	concat(U#addressBook.name, concat(" ", U#addressBook.surname)).

findByPhone(PhoneNumber, AB) ->
	U = hd(getContactByPhoneNumber(PhoneNumber, AB)),
	concat(U#addressBook.name, concat(" ", U#addressBook.surname)).

findWorkers(CompanyName, AB) ->
	[X || X<-AB, X#addressBook.companyName == CompanyName].

%%---------pomocnicze funkcje-----------

getContact(AB, Name, Surname) -> [X || X<-AB, X#addressBook.name == Name, X#addressBook.surname == Surname].

getOthers(AB, Name, Surname) -> 
	NotMatch = fun(U = #addressBook{}) when (U#addressBook.name /= Name) or (U#addressBook.surname /= Surname) -> 
					true; (_) -> false end,
	filter(NotMatch, AB).

getContactByEmail(Email, AB) -> [X || X<-AB, X#addressBook.email == Email].

getContactByPhoneNumber(PhoneNumber, AB) -> [X || X<-AB, X#addressBook.phoneNumber == PhoneNumber].

getOthersByEmail(Email, AB) -> [X || X<-AB, X#addressBook.email /= Email].

getOthersByPhoneNumber(PhoneNumber, AB) -> [X || X<-AB, X#addressBook.phoneNumber /= PhoneNumber].