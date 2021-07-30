# BillinhoApi

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Roteiro de testes manuais da API

Testes feitos em 30/07/2021, usando a aplicação de linha de comando [HTTPie](https://httpie.io) (`http` sendo um alias para `python3 -m httpie`).

### Banco recém-criado

#### Listagens funcionam com parâmetros válidos

```
$ http GET :4000/students page==1 count==3`

HTTP/1.1 200 OK
cache-control: max-age=0, private, must-revalidate
content-length: 21
content-type: application/json; charset=utf-8
date: Fri, 30 Jul 2021 04:14:43 GMT
server: Cowboy
x-request-id: FpZ2Y1YbBx2G9rgAAABF

{
    "items": [],
    "page": 1
}
```

```
$ http GET :4000/enrollments page==1 count==3

HTTP/1.1 200 OK
cache-control: max-age=0, private, must-revalidate
content-length: 21
content-type: application/json; charset=utf-8
date: Fri, 30 Jul 2021 04:17:02 GMT
server: Cowboy
x-request-id: FpZ2g7CvWgRW-vkAAAEj

{
    "items": [],
    "page": 1
}
```

#### Parâmetros de busca são validados

`page` e `count` devem ser positivos.

```
$ http GET :4000/students page==0 count==0

HTTP/1.1 400 Bad Request
cache-control: max-age=0, private, must-revalidate
content-length: 58
date: Fri, 30 Jul 2021 04:54:17 GMT
server: Cowboy
x-request-id: FpZ4i_NyM3S8BfwAAACj

{"count":["must be positive"],"page":["must be positive"]}
```

```
$ http GET :4000/enrollments page==0 count==0

HTTP/1.1 400 Bad Request
cache-control: max-age=0, private, must-revalidate
content-length: 58
date: Fri, 30 Jul 2021 05:00:08 GMT
server: Cowboy
x-request-id: FpZ43bef1mYHB2UAAAFh

{"count":["must be positive"],"page":["must be positive"]}

E devem estar presentes (semmas não tratamos o erro caso não estejam).
```

#### Criação de alunos

```
$ http POST :4000/students name="Zezinho da Silva" cpf=000.000.000-00 payment_method=boleto birthdate=01/01/2021

HTTP/1.1 200 OK
cache-control: max-age=0, private, must-revalidate
content-length: 8
content-type: application/json; charset=utf-8
date: Fri, 30 Jul 2021 05:03:07 GMT
server: Cowboy
x-request-id: FpZ5B2ZsCY9tJ3cAAALn

{
    "id": 1
}
```

```
$ http GET :4000/students page==1 count==3

HTTP/1.1 200 OK
cache-control: max-age=0, private, must-revalidate
content-length: 129
content-type: application/json; charset=utf-8
date: Fri, 30 Jul 2021 05:04:25 GMT
server: Cowboy
x-request-id: FpZ5GWjydurU3OoAAAGB

{
    "items": [
        {
            "birthdate": "01/01/2021",
            "cpf": "000.000.000-00",
            "id": 1,
            "name": "Zezinho da Silva",
            "payment_method": "boleto"
        }
    ],
    "page": 1
}
```

#### Validação dos parâmetros:

Apenas a data de nascimento é opcional.

```
$ http POST :4000/students

HTTP/1.1 400 Bad Request
cache-control: max-age=0, private, must-revalidate
content-length: 88
date: Fri, 30 Jul 2021 05:09:12 GMT
server: Cowboy
x-request-id: FpZ5XHFqAV_XuEkAAAKC

{"cpf":["can't be blank"],"name":["can't be blank"],"payment_method":["can't be blank"]}
```

Quando ela estiver presente, no entanto, precisa ser uma data válida no formato dd/mm/yyyy.

```
$ http POST :4000/students birthdate=30/02/2021

HTTP/1.1 400 Bad Request
cache-control: max-age=0, private, must-revalidate
content-length: 32
date: Fri, 30 Jul 2021 05:12:08 GMT
server: Cowboy
x-request-id: FpZ5hWXKINkmr1IAAACl

{"birthdate":["is unparseable"]}
```

Mas não validamos datas de nascimento no futuro.

```
$ http POST :4000/students name="Zequinha da Silva II" cpf=000.000.000-02 payment_method=credit_card birthdate=01/01/2038

HTTP/1.1 200 OK
cache-control: max-age=0, private, must-revalidate
content-length: 8
content-type: application/json; charset=utf-8
date: Fri, 30 Jul 2021 05:55:06 GMT
server: Cowboy
x-request-id: FpZ73Ze3K7MuAOEAAALi

{
    "id": 3
}
```

A forma de pagamento deve ser "boleto" ou "credit_card".

```
$ http POST :4000/students name="Zezinho da Silva" cpf=000.000.000-01 payment_method=cash birthdate=01/01/2021

HTTP/1.1 400 Bad Request
cache-control: max-age=0, private, must-revalidate
content-length: 33
date: Fri, 30 Jul 2021 05:16:25 GMT
server: Cowboy
x-request-id: FpZ5wTZr9NV0rPYAAAGG

{"payment_method":["is invalid"]}
```

O CPF deve ser único.

```
$ http POST :4000/students name="Zezinho da Silva" cpf=000.000.000-00 payment_method=credit_card birthdate=01/01/2021

HTTP/1.1 400 Bad Request
cache-control: max-age=0, private, must-revalidate
content-length: 34
date: Fri, 30 Jul 2021 05:17:30 GMT
server: Cowboy
x-request-id: FpZ50EJzW6azqfIAAAKi

{"cpf":["has already been taken"]}
```

Quando estas condições são atendidas, podemos cadastrar um novo aluno.

```
$ http POST :4000/students name="Zequinha da Silva" cpf=000.000.000-01 payment_method=credit_card birthdate=01/01/2021

HTTP/1.1 200 OK
cache-control: max-age=0, private, must-revalidate
content-length: 8
content-type: application/json; charset=utf-8
date: Fri, 30 Jul 2021 05:18:57 GMT
server: Cowboy
x-request-id: FpZ55HshzQI45GkAAAKD

{
    "id": 4
}
```

### Criação de matrículas

```
$ http --auth admin_ops:billing POST :4000/enrollments amount=1200 installments=3 due_day=10 student_id=1

HTTP/1.1 200 OK
cache-control: max-age=0, private, must-revalidate
content-length: 263
content-type: application/json; charset=utf-8
date: Fri, 30 Jul 2021 05:21:18 GMT
server: Cowboy
x-request-id: FpZ6BWzS4g5dq9wAAANH

{
    "amount": 1200,
    "bills": [
        {
            "amount": 400,
            "due_date": "10/08/2021",
            "id": 1,
            "status": "open"
        },
        {
            "amount": 400,
            "due_date": "10/09/2021",
            "id": 2,
            "status": "open"
        },
        {
            "amount": 400,
            "due_date": "10/10/2021",
            "id": 3,
            "status": "open"
        }
    ],
    "due_day": 10,
    "id": 1,
    "installments": 3,
    "student_id": 1
}
```

Sem as credenciais corretas, não é possível cadastrar uma matrícula.

```
$ http --auth not_admin:billing POST :4000/enrollments amount=1200 installments=3 due_day=10 student_id=1

HTTP/1.1 401 Unauthorized
cache-control: max-age=0, private, must-revalidate
content-length: 12
date: Fri, 30 Jul 2021 05:22:45 GMT
server: Cowboy
www-authenticate: Basic realm="Application"
x-request-id: FpZ6Gb1BlcDg5Y8AAAIB

Unauthorized
```

#### Validação dos parâmetros

Todos os parâmetros são obrigatórios.

```
$ http --auth admin_ops:billing POST :4000/enrollments

HTTP/1.1 400 Bad Request
cache-control: max-age=0, private, must-revalidate
content-length: 124
date: Fri, 30 Jul 2021 05:26:34 GMT
server: Cowboy
x-request-id: FpZ6TxPJ8eBAYrQAAABk

{"amount":["can't be blank"],"due_day":["can't be blank"],"installments":["can't be blank"],"student_id":["can't be blank"]}
```

A matrícula deve estar associada a um aluno.

```
$ http --auth admin_ops:billing POST :4000/enrollments amount=1200 installments=3 due_day=10 student_id=446546

HTTP/1.1 400 Bad Request
cache-control: max-age=0, private, must-revalidate
content-length: 33
date: Fri, 30 Jul 2021 05:25:03 GMT
server: Cowboy
x-request-id: FpZ6ObfDt-2ZttoAAASo

{"student_id":["does not exist"]}
```

Todos os parâmetros devem ser inteiros.

```
$ http --auth admin_ops:billing POST :4000/enrollments amount=120.234 installments=2g2 due_day=ad student_id=1.0

HTTP/1.1 400 Bad Request
cache-control: max-age=0, private, must-revalidate
content-length: 140
date: Fri, 30 Jul 2021 05:27:48 GMT
server: Cowboy
x-request-id: FpZ6YF3ka1MVjFQAAAGm

{"amount":["must be an integer"],"due_day":["must be an integer"],"installments":["must be an integer"],"student_id":["must be an integer"]}
```

O valor da matrícula deve ser positivo; o número de mensalidades deve ser maior que 1; o dia de vencimento deve estar entre 1 e 31.

```
$ http --auth admin_ops:billing POST :4000/enrollments amount=0 installments=1 due_day=32 student_id=1

HTTP/1.1 400 Bad Request
cache-control: max-age=0, private, must-revalidate
content-length: 104
date: Fri, 30 Jul 2021 05:30:52 GMT
server: Cowboy
x-request-id: FpZ6iyz6BAjC8-wAAACE

{"amount":["must be greater than 0"],"due_day":["is invalid"],"installments":["must be greater than 1"]}
```

Se os dados da matrícula forem válidos, os das mensalidades também os serão: o valor de cada uma é o valor da matrícula dividido pelo número de mensalidades.

```
$ http --auth admin_ops:billing POST :4000/enrollments amount=360 installments=3 due_day=25 student_id=1

HTTP/1.1 200 OK
cache-control: max-age=0, private, must-revalidate
content-length: 262
content-type: application/json; charset=utf-8
date: Fri, 30 Jul 2021 05:35:56 GMT
server: Cowboy
x-request-id: FpZ60cn_1PPnEVQAAALC

{
    "amount": 360,
    "bills": [
        {
            "amount": 120,
            "due_date": "25/08/2021",
            "id": 4,
            "status": "open"
        },
        {
            "amount": 120,
            "due_date": "25/09/2021",
            "id": 5,
            "status": "open"
        },
        {
            "amount": 120,
            "due_date": "25/10/2021",
            "id": 6,
            "status": "open"
        }
    ],
    "due_day": 25,
    "id": 3,
    "installments": 3,
    "student_id": 1
}
```

Elas nem sempre terão os mesmos valores, mas a some delas sempre será igual ao valor da matrícula.

```
$ http --auth admin_ops:billing POST :4000/enrollments amount=152 installments=3 due_day=25 student_id=1

HTTP/1.1 200 OK
cache-control: max-age=0, private, must-revalidate
content-length: 259
content-type: application/json; charset=utf-8
date: Fri, 30 Jul 2021 05:37:33 GMT
server: Cowboy
x-request-id: FpZ66FZKQvr_TToAAACk

{
    "amount": 152,
    "bills": [
        {
            "amount": 50,
            "due_date": "25/08/2021",
            "id": 7,
            "status": "open"
        },
        {
            "amount": 51,
            "due_date": "25/09/2021",
            "id": 8,
            "status": "open"
        },
        {
            "amount": 51,
            "due_date": "25/10/2021",
            "id": 9,
            "status": "open"
        }
    ],
    "due_day": 25,
    "id": 4,
    "installments": 3,
    "student_id": 1
}
```

A data de pagamento das mensalidades e calculada com base no dia de vencimento da matrícula, respeitando o número de dias de cada mês.

```
$ http --auth admin_ops:billing POST :4000/enrollments amount=300 installments=4 due_day=31 student_id=1

HTTP/1.1 200 OK
cache-control: max-age=0, private, must-revalidate
content-length: 324
content-type: application/json; charset=utf-8
date: Fri, 30 Jul 2021 05:42:41 GMT
server: Cowboy
x-request-id: FpZ7MBANDqd6H3UAAAKj

{
    "amount": 300,
    "bills": [
        {
            "amount": 75,
            "due_date": "31/07/2021",
            "id": 13,
            "status": "open"
        },
        {
            "amount": 75,
            "due_date": "31/08/2021",
            "id": 14,
            "status": "open"
        },
        {
            "amount": 75,
            "due_date": "30/09/2021",
            "id": 15,
            "status": "open"
        },
        {
            "amount": 75,
            "due_date": "31/10/2021",
            "id": 16,
            "status": "open"
        }
    ],
    "due_day": 31,
    "id": 6,
    "installments": 4,
    "student_id": 1
}
```