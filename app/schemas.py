from __future__ import annotations

from marshmallow import Schema, fields, validate


class TodoCreateSchema(Schema):
    title = fields.String(required=True, validate=validate.Length(min=1, max=120))
    done = fields.Boolean(load_default=False)


class TodoUpdateSchema(Schema):
    title = fields.String(validate=validate.Length(min=1, max=120))
    done = fields.Boolean()


